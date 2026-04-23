//
//  PokemonDetailViewModelTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

@MainActor
final class PokemonDetailViewModelTests: XCTestCase {

    func test_isLoading_isTrue_initially() {
        let viewModel = makeViewModel()

        XCTAssertTrue(viewModel.isLoading)
    }

    func test_detail_isNil_initially() {
        let viewModel = makeViewModel()

        XCTAssertNil(viewModel.detail)
    }

    func test_getDetail_updatesDetailOnSuccess() async {
        let viewModel = makeViewModel(detail: .mock)

        await viewModel.getDetail()

        XCTAssertEqual(viewModel.detail?.id, PokemonDetail.mock.id)
        XCTAssertEqual(viewModel.detail?.name, PokemonDetail.mock.name)
        XCTAssertEqual(viewModel.detail?.slug, PokemonDetail.mock.slug)
        XCTAssertEqual(viewModel.detail?.types, PokemonDetail.mock.types)
    }

    func test_getDetail_setsIsLoadingFalse_afterSuccess() async {
        let viewModel = makeViewModel(detail: .mock)

        await viewModel.getDetail()

        XCTAssertFalse(viewModel.isLoading)
    }

    func test_getDetail_doesNotUpdateDetail_onError() async {
        let viewModel = makeViewModel(error: URLError(.notConnectedToInternet))

        await viewModel.getDetail()

        XCTAssertNil(viewModel.detail)
    }

    func test_getDetail_setsIsLoadingFalse_afterError() async {
        let viewModel = makeViewModel(error: URLError(.notConnectedToInternet))

        await viewModel.getDetail()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - errorMessage

    func test_getDetail_setsErrorMessage_onError() async {
        let viewModel = makeViewModel(error: URLError(.notConnectedToInternet))

        await viewModel.getDetail()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_getDetail_doesNotSetErrorMessage_onSuccess() async {
        let viewModel = makeViewModel(detail: .mock)

        await viewModel.getDetail()

        XCTAssertNil(viewModel.errorMessage)
    }

    func test_dismissError_clearsErrorMessage() async {
        let viewModel = makeViewModel(error: URLError(.notConnectedToInternet))
        await viewModel.getDetail()

        viewModel.dismissError()

        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - favourites

    func test_isFavorite_isFalse_initially() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.isFavorite)
    }

    func test_isFavorite_isTrue_whenPokemonIsAlreadyFavorite() {
        let viewModel = makeViewModel(favoriteIDs: [PokemonDetail.mock.id])

        XCTAssertTrue(viewModel.isFavorite)
    }

    func test_toggleFavorite_setsIsFavoriteTrue_afterLoading() async {
        let viewModel = makeViewModel()
        await viewModel.getDetail()

        viewModel.toggleFavorite()

        XCTAssertTrue(viewModel.isFavorite)
    }

    func test_toggleFavorite_setsIsFavoriteFalse_whenAlreadyFavorite() async {
        let viewModel = makeViewModel(favoriteIDs: [PokemonDetail.mock.id])
        await viewModel.getDetail()

        viewModel.toggleFavorite()

        XCTAssertFalse(viewModel.isFavorite)
    }

    func test_toggleFavorite_doesNothing_whenDetailIsNil() async {
        let viewModel = makeViewModel(error: URLError(.notConnectedToInternet))
        await viewModel.getDetail()

        viewModel.toggleFavorite()

        XCTAssertFalse(viewModel.isFavorite)
    }

    // MARK: - Helpers

    private func makeViewModel(
        detail: PokemonDetail = .mock,
        error: Error? = nil,
        favoriteIDs: Set<Int> = []
    ) -> PokemonDetailViewModel {
        let detailUseCase = error.map { MockGetPokemonDetailUseCase(error: $0) }
            ?? MockGetPokemonDetailUseCase(detail: detail)
        let toggleUseCase = MockToggleFavoriteUseCase(favoriteIDs: favoriteIDs)
        return PokemonDetailViewModel(
            pokemonID: detail.id,
            getPokemonDetailUseCase: detailUseCase,
            toggleFavoriteUseCase: toggleUseCase
        )
    }
}
