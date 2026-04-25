import Foundation
import Nimble
import Quick
@testable import WallaMarvel

final class PokemonListViewModelSpec: AsyncSpec {
    override class func spec() {
        @MainActor
        func makeViewModel(
            listPokemon: [Pokemon] = [],
            listError: Error? = nil,
            searchResult: Pokemon? = nil,
            searchError: Error? = nil,
            typesByType: [Pokemon] = [],
            typesByTypeError: Error? = nil,
            pokemonTypes: [String] = [],
            pokemonTypesError: Error? = nil,
            favorites: [Pokemon] = [],
            favoriteIDs: Set<Int> = []
        ) -> PokemonListViewModel {
            PokemonListViewModel(
                getPokemonListUseCase: listError.map { MockGetPokemonListUseCase(error: $0) }
                    ?? MockGetPokemonListUseCase(pokemon: listPokemon),
                searchPokemonUseCase: searchError.map { MockSearchPokemonUseCase(error: $0) }
                    ?? MockSearchPokemonUseCase(pokemon: searchResult ?? Pokemon(id: 0, name: "", imageURL: URL(string: "https://example.com")!)),
                getPokemonByTypeUseCase: typesByTypeError.map { MockGetPokemonByTypeUseCase(error: $0) }
                    ?? MockGetPokemonByTypeUseCase(pokemon: typesByType),
                getPokemonTypesUseCase: pokemonTypesError.map { MockGetPokemonTypesUseCase(error: $0) }
                    ?? MockGetPokemonTypesUseCase(types: pokemonTypes),
                toggleFavoriteUseCase: MockToggleFavoriteUseCase(favoriteIDs: favoriteIDs),
                getFavoritesUseCase: MockGetFavoritesUseCase(favorites: favorites)
            )
        }

        describe("PokemonListViewModel") {
            describe("title") {
                it("returns Pokédex") {
                    let sut = await makeViewModel()
                    let title = await sut.title
                    expect(title) == "Pokédex"
                }
            }

            describe("getPokemon") {
                context("when the API succeeds") {
                    it("populates the pokemon list") {
                        let sut = await makeViewModel(listPokemon: [
                            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
                            Pokemon(id: 2, name: "Ivysaur", imageURL: URL(string: "https://example.com/2.png")!),
                        ])
                        await sut.getPokemon()
                        let result = await sut.pokemon
                        expect(result).to(haveCount(2))
                        expect(result.first?.name) == "Bulbasaur"
                    }

                    it("does not set an error message") {
                        let sut = await makeViewModel(listPokemon: [
                            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
                        ])
                        await sut.getPokemon()
                        let errorMessage = await sut.errorMessage
                        expect(errorMessage).to(beNil())
                    }
                }

                context("when the API fails") {
                    it("leaves the pokemon list empty") {
                        let sut = await makeViewModel(listError: URLError(.notConnectedToInternet))
                        await sut.getPokemon()
                        let result = await sut.pokemon
                        expect(result).to(beEmpty())
                    }

                    it("sets an error message") {
                        let sut = await makeViewModel(listError: URLError(.notConnectedToInternet))
                        await sut.getPokemon()
                        let errorMessage = await sut.errorMessage
                        expect(errorMessage).toNot(beNil())
                    }
                }
            }

            describe("isSearching") {
                it("is false when searchText is empty") {
                    let sut = await makeViewModel()
                    let isSearching = await sut.isSearching
                    expect(isSearching) == false
                }

                it("is true when searchText is not empty") {
                    let sut = await makeViewModel()
                    await MainActor.run { sut.searchText = "bulbasaur" }
                    let isSearching = await sut.isSearching
                    expect(isSearching) == true
                }
            }

            describe("searchPokemon") {
                context("when the search succeeds") {
                    it("sets searchResult and clears searchNotFound") {
                        let expected = Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!)
                        let sut = await makeViewModel(searchResult: expected)
                        await MainActor.run { sut.searchText = "bulbasaur" }
                        await sut.searchPokemon()
                        let searchResult = await sut.searchResult
                        let searchNotFound = await sut.searchNotFound
                        expect(searchResult?.id) == expected.id
                        expect(searchResult?.name) == expected.name
                        expect(searchNotFound) == false
                    }
                }

                context("when the search fails") {
                    it("clears searchResult and sets searchNotFound") {
                        let sut = await makeViewModel(searchError: URLError(.notConnectedToInternet))
                        await MainActor.run { sut.searchText = "unknownmon" }
                        await sut.searchPokemon()
                        let searchResult = await sut.searchResult
                        let searchNotFound = await sut.searchNotFound
                        expect(searchResult).to(beNil())
                        expect(searchNotFound) == true
                    }
                }
            }

            describe("clearSearch") {
                it("resets all search state") {
                    let sut = await makeViewModel(searchResult: Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!))
                    await MainActor.run { sut.searchText = "bulbasaur" }
                    await sut.searchPokemon()
                    await MainActor.run { sut.clearSearch() }
                    let searchText = await sut.searchText
                    let searchResult = await sut.searchResult
                    let searchNotFound = await sut.searchNotFound
                    expect(searchText) == ""
                    expect(searchResult).to(beNil())
                    expect(searchNotFound) == false
                }
            }

            describe("dismissError") {
                it("clears the error message") {
                    let sut = await makeViewModel(listError: URLError(.notConnectedToInternet))
                    await sut.getPokemon()
                    await MainActor.run { sut.dismissError() }
                    let errorMessage = await sut.errorMessage
                    expect(errorMessage).to(beNil())
                }
            }

            describe("loadTypes") {
                context("when the API succeeds") {
                    it("populates pokemonTypes") {
                        let sut = await makeViewModel(pokemonTypes: ["fire", "water", "grass"])
                        await sut.loadTypes()
                        let types = await sut.pokemonTypes
                        expect(types) == ["fire", "water", "grass"]
                    }
                }

                context("when the API fails") {
                    it("leaves pokemonTypes empty") {
                        let sut = await makeViewModel(pokemonTypesError: URLError(.notConnectedToInternet))
                        await sut.loadTypes()
                        let types = await sut.pokemonTypes
                        expect(types).to(beEmpty())
                    }
                }
            }

            describe("selectType") {
                context("when a new type is selected") {
                    it("sets selectedType") {
                        let sut = await makeViewModel()
                        await sut.selectType("fire")
                        let selectedType = await sut.selectedType
                        expect(selectedType) == "fire"
                    }

                    it("populates filteredPokemon on success") {
                        let sut = await makeViewModel(typesByType: [
                            Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!),
                        ])
                        await sut.selectType("fire")
                        let filtered = await sut.filteredPokemon
                        expect(filtered).to(haveCount(1))
                        expect(filtered.first?.name) == "Charmander"
                    }

                    it("clears showingFavoritesOnly") {
                        let sut = await makeViewModel()
                        await MainActor.run { sut.toggleShowFavoritesOnly() }
                        await sut.selectType("fire")
                        let showingFavoritesOnly = await sut.showingFavoritesOnly
                        expect(showingFavoritesOnly) == false
                    }
                }

                context("when the same type is selected again") {
                    it("deselects and clears filteredPokemon") {
                        let sut = await makeViewModel(typesByType: [
                            Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!),
                        ])
                        await sut.selectType("fire")
                        await sut.selectType("fire")
                        let selectedType = await sut.selectedType
                        let filtered = await sut.filteredPokemon
                        expect(selectedType).to(beNil())
                        expect(filtered).to(beEmpty())
                    }
                }

                context("when a different type is selected") {
                    it("replaces filteredPokemon with the new type's results") {
                        let sut = await makeViewModel(typesByType: [
                            Pokemon(id: 7, name: "Squirtle", imageURL: URL(string: "https://example.com/7.png")!),
                        ])
                        await sut.selectType("fire")
                        await sut.selectType("water")
                        let selectedType = await sut.selectedType
                        let filtered = await sut.filteredPokemon
                        expect(selectedType) == "water"
                        expect(filtered.first?.name) == "Squirtle"
                    }
                }

                context("when the API fails") {
                    it("resets selectedType, sets an error, and clears filteredPokemon") {
                        let sut = await makeViewModel(typesByTypeError: URLError(.notConnectedToInternet))
                        await sut.selectType("fire")
                        let selectedType = await sut.selectedType
                        let errorMessage = await sut.errorMessage
                        let filtered = await sut.filteredPokemon
                        expect(selectedType).to(beNil())
                        expect(errorMessage).toNot(beNil())
                        expect(filtered).to(beEmpty())
                    }
                }
            }

            describe("toggleShowFavoritesOnly") {
                it("sets showingFavoritesOnly to true") {
                    let sut = await makeViewModel()
                    await MainActor.run { sut.toggleShowFavoritesOnly() }
                    let showingFavoritesOnly = await sut.showingFavoritesOnly
                    expect(showingFavoritesOnly) == true
                }

                it("turns off when called twice") {
                    let sut = await makeViewModel()
                    await MainActor.run {
                        sut.toggleShowFavoritesOnly()
                        sut.toggleShowFavoritesOnly()
                    }
                    let showingFavoritesOnly = await sut.showingFavoritesOnly
                    expect(showingFavoritesOnly) == false
                }

                it("clears selectedType and filteredPokemon") {
                    let sut = await makeViewModel(typesByType: [
                        Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!),
                    ])
                    await sut.selectType("fire")
                    await MainActor.run { sut.toggleShowFavoritesOnly() }
                    let selectedType = await sut.selectedType
                    let filtered = await sut.filteredPokemon
                    expect(selectedType).to(beNil())
                    expect(filtered).to(beEmpty())
                }
            }

            describe("loadFavorites") {
                it("populates favorites") {
                    let sut = await makeViewModel(favorites: [
                        Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
                    ])
                    await MainActor.run { sut.loadFavorites() }
                    let favorites = await sut.favorites
                    expect(favorites).to(haveCount(1))
                    expect(favorites.first?.name) == "Bulbasaur"
                }
            }

            describe("isFavorite") {
                it("returns true when the pokemon is in favorites") {
                    let pokemon = Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!)
                    let sut = await makeViewModel(favoriteIDs: [1])
                    let isFavorite = await sut.isFavorite(pokemon)
                    expect(isFavorite) == true
                }

                it("returns false when the pokemon is not in favorites") {
                    let pokemon = Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!)
                    let sut = await makeViewModel()
                    let isFavorite = await sut.isFavorite(pokemon)
                    expect(isFavorite) == false
                }
            }

            describe("displayedPokemon") {
                context("when showingFavoritesOnly is true") {
                    it("returns favorites") {
                        let sut = await makeViewModel(favorites: [
                            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
                        ])
                        await MainActor.run { sut.toggleShowFavoritesOnly() }
                        let displayed = await sut.displayedPokemon
                        expect(displayed).to(haveCount(1))
                        expect(displayed.first?.name) == "Bulbasaur"
                    }
                }

                context("when a type filter is active") {
                    it("returns filteredPokemon") {
                        let sut = await makeViewModel(typesByType: [
                            Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!),
                        ])
                        await sut.selectType("fire")
                        let displayed = await sut.displayedPokemon
                        expect(displayed).to(haveCount(1))
                        expect(displayed.first?.name) == "Charmander"
                    }
                }

                context("when no filter is active") {
                    it("returns all pokemon") {
                        let sut = await makeViewModel(listPokemon: [
                            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
                            Pokemon(id: 2, name: "Ivysaur", imageURL: URL(string: "https://example.com/2.png")!),
                        ])
                        await sut.getPokemon()
                        let displayed = await sut.displayedPokemon
                        expect(displayed).to(haveCount(2))
                    }
                }
            }

            describe("hasSearched") {
                it("is false initially") {
                    let sut = await makeViewModel()
                    let hasSearched = await sut.hasSearched
                    expect(hasSearched) == false
                }

                it("becomes true after a search") {
                    let sut = await makeViewModel()
                    await MainActor.run { sut.searchText = "bulbasaur" }
                    await sut.searchPokemon()
                    let hasSearched = await sut.hasSearched
                    expect(hasSearched) == true
                }

                it("becomes true after a failed search") {
                    let sut = await makeViewModel(searchError: URLError(.notConnectedToInternet))
                    await MainActor.run { sut.searchText = "unknownmon" }
                    await sut.searchPokemon()
                    let hasSearched = await sut.hasSearched
                    expect(hasSearched) == true
                }

                it("resets after clearSearch") {
                    let sut = await makeViewModel()
                    await MainActor.run { sut.searchText = "bulbasaur" }
                    await sut.searchPokemon()
                    await MainActor.run { sut.clearSearch() }
                    let hasSearched = await sut.hasSearched
                    expect(hasSearched) == false
                }

                it("resets after resetSearchResults without clearing searchText") {
                    let sut = await makeViewModel(searchError: URLError(.notConnectedToInternet))
                    await MainActor.run { sut.searchText = "bulb" }
                    await sut.searchPokemon()
                    await MainActor.run { sut.resetSearchResults() }
                    let hasSearched = await sut.hasSearched
                    let searchNotFound = await sut.searchNotFound
                    let searchResult = await sut.searchResult
                    let searchText = await sut.searchText
                    expect(hasSearched) == false
                    expect(searchNotFound) == false
                    expect(searchResult).to(beNil())
                    expect(searchText) == "bulb"
                }
            }
        }
    }
}
