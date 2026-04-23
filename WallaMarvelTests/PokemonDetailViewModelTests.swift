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

    // MARK: - Helpers

    private func makeViewModel(
        detail: PokemonDetail = .mock,
        error: Error? = nil
    ) -> PokemonDetailViewModel {
        let useCase = error.map { MockGetPokemonDetailUseCase(error: $0) }
            ?? MockGetPokemonDetailUseCase(detail: detail)
        return PokemonDetailViewModel(pokemonID: detail.id, getPokemonDetailUseCase: useCase)
    }
}
