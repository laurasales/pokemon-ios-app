//
//  ListPokemonViewModelTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

@MainActor
final class ListPokemonViewModelTests: XCTestCase {

    func test_title_returnsPokedex() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.title, "Pokédex")
    }

    // MARK: - getPokemon

    func test_getPokemon_updatesPokemonOnSuccess() async {
        let expectedPokemon = [
            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
            Pokemon(id: 2, name: "Ivysaur", imageURL: URL(string: "https://example.com/2.png")!)
        ]
        let viewModel = makeViewModel(listPokemon: expectedPokemon)

        await viewModel.getPokemon()

        XCTAssertEqual(viewModel.pokemon.count, 2)
        XCTAssertEqual(viewModel.pokemon.first?.name, "Bulbasaur")
    }

    func test_getPokemon_doesNotUpdatePokemonOnError() async {
        let viewModel = makeViewModel(listError: URLError(.notConnectedToInternet))

        await viewModel.getPokemon()

        XCTAssertTrue(viewModel.pokemon.isEmpty)
    }

    // MARK: - searchPokemon

    func test_isSearching_isFalse_whenSearchTextIsEmpty() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.isSearching)
    }

    func test_isSearching_isTrue_whenSearchTextIsNotEmpty() {
        let viewModel = makeViewModel()
        viewModel.searchText = "bulbasaur"

        XCTAssertTrue(viewModel.isSearching)
    }

    func test_searchPokemon_setsResultOnSuccess() async {
        let expected = Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!)
        let viewModel = makeViewModel(searchResult: expected)
        viewModel.searchText = "bulbasaur"

        await viewModel.searchPokemon()

        XCTAssertEqual(viewModel.searchResult?.id, expected.id)
        XCTAssertEqual(viewModel.searchResult?.name, expected.name)
        XCTAssertFalse(viewModel.searchNotFound)
    }

    func test_searchPokemon_setsSearchNotFound_onError() async {
        let viewModel = makeViewModel(searchError: URLError(.notConnectedToInternet))
        viewModel.searchText = "unknownmon"

        await viewModel.searchPokemon()

        XCTAssertNil(viewModel.searchResult)
        XCTAssertTrue(viewModel.searchNotFound)
    }

    func test_clearSearch_resetsSearchState() async {
        let expected = Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!)
        let viewModel = makeViewModel(searchResult: expected)
        viewModel.searchText = "bulbasaur"
        await viewModel.searchPokemon()

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.searchResult)
        XCTAssertFalse(viewModel.searchNotFound)
    }

    // MARK: - loadTypes

    func test_loadTypes_updatesPokemonTypes_onSuccess() async {
        let viewModel = makeViewModel(pokemonTypes: ["fire", "water", "grass"])

        await viewModel.loadTypes()

        XCTAssertEqual(viewModel.pokemonTypes, ["fire", "water", "grass"])
    }

    func test_loadTypes_keepsPokemonTypesEmpty_onError() async {
        let viewModel = makeViewModel(pokemonTypesError: URLError(.notConnectedToInternet))

        await viewModel.loadTypes()

        XCTAssertTrue(viewModel.pokemonTypes.isEmpty)
    }

    // MARK: - selectType

    func test_selectType_setsSelectedType() async {
        let viewModel = makeViewModel()

        await viewModel.selectType("fire")

        XCTAssertEqual(viewModel.selectedType, "fire")
    }

    func test_selectType_setsFilteredPokemon_onSuccess() async {
        let expected = [
            Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!)
        ]
        let viewModel = makeViewModel(typesByType: expected)

        await viewModel.selectType("fire")

        XCTAssertEqual(viewModel.filteredPokemon.count, 1)
        XCTAssertEqual(viewModel.filteredPokemon.first?.name, "Charmander")
    }

    func test_selectType_deselects_whenSameTypeSelected() async {
        let viewModel = makeViewModel(typesByType: [
            Pokemon(id: 4, name: "Charmander", imageURL: URL(string: "https://example.com/4.png")!)
        ])
        await viewModel.selectType("fire")

        await viewModel.selectType("fire")

        XCTAssertNil(viewModel.selectedType)
        XCTAssertTrue(viewModel.filteredPokemon.isEmpty)
    }

    func test_selectType_clearsFilteredPokemon_onError() async {
        let viewModel = makeViewModel(typesByTypeError: URLError(.notConnectedToInternet))

        await viewModel.selectType("fire")

        XCTAssertTrue(viewModel.filteredPokemon.isEmpty)
    }

    func test_selectType_replacesFilteredPokemon_whenDifferentTypeSelected() async {
        let viewModel = makeViewModel(typesByType: [
            Pokemon(id: 7, name: "Squirtle", imageURL: URL(string: "https://example.com/7.png")!)
        ])
        await viewModel.selectType("fire")
        await viewModel.selectType("water")

        XCTAssertEqual(viewModel.selectedType, "water")
        XCTAssertEqual(viewModel.filteredPokemon.first?.name, "Squirtle")
    }

    // MARK: - Helpers

    private func makeViewModel(
        listPokemon: [Pokemon] = [],
        listError: Error? = nil,
        searchResult: Pokemon? = nil,
        searchError: Error? = nil,
        typesByType: [Pokemon] = [],
        typesByTypeError: Error? = nil,
        pokemonTypes: [String] = [],
        pokemonTypesError: Error? = nil
    ) -> ListPokemonViewModel {
        let listUseCase = listError.map { MockGetPokemonListUseCase(error: $0) }
            ?? MockGetPokemonListUseCase(pokemon: listPokemon)
        let searchUseCase = searchError.map { MockSearchPokemonUseCase(error: $0) }
            ?? MockSearchPokemonUseCase(pokemon: searchResult ?? Pokemon(id: 0, name: "", imageURL: URL(string: "https://example.com")!))
        let byTypeUseCase = typesByTypeError.map { MockGetPokemonByTypeUseCase(error: $0) }
            ?? MockGetPokemonByTypeUseCase(pokemon: typesByType)
        let typesUseCase = pokemonTypesError.map { MockGetPokemonTypesUseCase(error: $0) }
            ?? MockGetPokemonTypesUseCase(types: pokemonTypes)
        return ListPokemonViewModel(
            getPokemonListUseCase: listUseCase,
            searchPokemonUseCase: searchUseCase,
            getPokemonByTypeUseCase: byTypeUseCase,
            getPokemonTypesUseCase: typesUseCase
        )
    }
}
