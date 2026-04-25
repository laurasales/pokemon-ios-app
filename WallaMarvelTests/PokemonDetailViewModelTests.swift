import Foundation
import Nimble
import Quick
@testable import WallaMarvel

final class PokemonDetailViewModelSpec: AsyncSpec {
    override class func spec() {
        @MainActor
        func makeViewModel(
            detail: PokemonDetail = .mock,
            error: Error? = nil,
            favoriteIDs: Set<Int> = []
        ) -> PokemonDetailViewModel {
            PokemonDetailViewModel(
                pokemonID: detail.id,
                getPokemonDetailUseCase: error.map { MockGetPokemonDetailUseCase(error: $0) }
                    ?? MockGetPokemonDetailUseCase(detail: detail),
                toggleFavoriteUseCase: MockToggleFavoriteUseCase(favoriteIDs: favoriteIDs)
            )
        }

        describe("PokemonDetailViewModel") {
            describe("initial state") {
                it("isLoading is true") {
                    let sut = await makeViewModel()
                    let isLoading = await sut.isLoading
                    expect(isLoading) == true
                }

                it("detail is nil") {
                    let sut = await makeViewModel()
                    let detail = await sut.detail
                    expect(detail).to(beNil())
                }

                it("isFavorite is false when pokemon is not in favorites") {
                    let sut = await makeViewModel()
                    let isFavorite = await sut.isFavorite
                    expect(isFavorite) == false
                }

                it("isFavorite is true when pokemon is already a favorite") {
                    let sut = await makeViewModel(favoriteIDs: [PokemonDetail.mock.id])
                    let isFavorite = await sut.isFavorite
                    expect(isFavorite) == true
                }
            }

            describe("getDetail") {
                context("when the API succeeds") {
                    it("populates detail") {
                        let sut = await makeViewModel(detail: .mock)
                        await sut.getDetail()
                        let detail = await sut.detail
                        expect(detail?.id) == PokemonDetail.mock.id
                        expect(detail?.name) == PokemonDetail.mock.name
                        expect(detail?.slug) == PokemonDetail.mock.slug
                        expect(detail?.types) == PokemonDetail.mock.types
                    }

                    it("sets isLoading to false") {
                        let sut = await makeViewModel(detail: .mock)
                        await sut.getDetail()
                        let isLoading = await sut.isLoading
                        expect(isLoading) == false
                    }

                    it("does not set an error message") {
                        let sut = await makeViewModel(detail: .mock)
                        await sut.getDetail()
                        let errorMessage = await sut.errorMessage
                        expect(errorMessage).to(beNil())
                    }
                }

                context("when the API fails") {
                    it("leaves detail nil") {
                        let sut = await makeViewModel(error: URLError(.notConnectedToInternet))
                        await sut.getDetail()
                        let detail = await sut.detail
                        expect(detail).to(beNil())
                    }

                    it("sets isLoading to false") {
                        let sut = await makeViewModel(error: URLError(.notConnectedToInternet))
                        await sut.getDetail()
                        let isLoading = await sut.isLoading
                        expect(isLoading) == false
                    }

                    it("sets an error message") {
                        let sut = await makeViewModel(error: URLError(.notConnectedToInternet))
                        await sut.getDetail()
                        let errorMessage = await sut.errorMessage
                        expect(errorMessage).toNot(beNil())
                    }
                }
            }

            describe("dismissError") {
                it("clears the error message") {
                    let sut = await makeViewModel(error: URLError(.notConnectedToInternet))
                    await sut.getDetail()
                    await MainActor.run { sut.dismissError() }
                    let errorMessage = await sut.errorMessage
                    expect(errorMessage).to(beNil())
                }
            }

            describe("toggleFavorite") {
                context("when detail has loaded") {
                    it("sets isFavorite to true") {
                        let sut = await makeViewModel()
                        await sut.getDetail()
                        await MainActor.run { sut.toggleFavorite() }
                        let isFavorite = await sut.isFavorite
                        expect(isFavorite) == true
                    }

                    it("sets isFavorite to false when already a favorite") {
                        let sut = await makeViewModel(favoriteIDs: [PokemonDetail.mock.id])
                        await sut.getDetail()
                        await MainActor.run { sut.toggleFavorite() }
                        let isFavorite = await sut.isFavorite
                        expect(isFavorite) == false
                    }
                }

                context("when detail has not loaded") {
                    it("does nothing") {
                        let sut = await makeViewModel(error: URLError(.notConnectedToInternet))
                        await sut.getDetail()
                        await MainActor.run { sut.toggleFavorite() }
                        let isFavorite = await sut.isFavorite
                        expect(isFavorite) == false
                    }
                }
            }
        }
    }
}
