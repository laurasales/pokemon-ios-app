//
//  ListPokemonPresenterTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

@MainActor
final class ListPokemonViewModelTests: XCTestCase {

    func test_title_returnsPokedex() {
        let viewModel = ListPokemonViewModel(getPokemonListUseCase: MockGetPokemonListUseCase(pokemon: []))

        XCTAssertEqual(viewModel.title, "Pokédex")
    }

    func test_getPokemon_updatesPokemonOnSuccess() async {
        let expectedPokemon = [
            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
            Pokemon(id: 2, name: "Ivysaur", imageURL: URL(string: "https://example.com/2.png")!)
        ]
        let viewModel = ListPokemonViewModel(getPokemonListUseCase: MockGetPokemonListUseCase(pokemon: expectedPokemon))

        await viewModel.getPokemon()

        XCTAssertEqual(viewModel.pokemon.count, 2)
        XCTAssertEqual(viewModel.pokemon.first?.name, "Bulbasaur")
    }

    func test_getPokemon_doesNotUpdatePokemonOnError() async {
        let viewModel = ListPokemonViewModel(
            getPokemonListUseCase: MockGetPokemonListUseCase(error: URLError(.notConnectedToInternet))
        )

        await viewModel.getPokemon()

        XCTAssertTrue(viewModel.pokemon.isEmpty)
    }
}

// MARK: - Mocks

private final class MockGetPokemonListUseCase: GetPokemonListUseCaseProtocol {
    private let result: Result<[Pokemon], Error>

    init(pokemon: [Pokemon]) {
        self.result = .success(pokemon)
    }

    init(error: Error) {
        self.result = .failure(error)
    }

    func execute(limit: Int, offset: Int) async throws -> [Pokemon] {
        try result.get()
    }
}
