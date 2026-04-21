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

    // MARK: - Helpers

    private func makeViewModel(
        listPokemon: [Pokemon] = [],
        listError: Error? = nil,
        searchResult: Pokemon? = nil,
        searchError: Error? = nil
    ) -> ListPokemonViewModel {
        let listUseCase = listError.map { MockGetPokemonListUseCase(error: $0) }
            ?? MockGetPokemonListUseCase(pokemon: listPokemon)
        let searchUseCase = searchError.map { MockSearchPokemonUseCase(error: $0) }
            ?? MockSearchPokemonUseCase(pokemon: searchResult ?? Pokemon(id: 0, name: "", imageURL: URL(string: "https://example.com")!))
        return ListPokemonViewModel(
            getPokemonListUseCase: listUseCase,
            searchPokemonUseCase: searchUseCase
        )
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

private final class MockSearchPokemonUseCase: SearchPokemonUseCaseProtocol {
    private let result: Result<Pokemon, Error>

    init(pokemon: Pokemon) {
        self.result = .success(pokemon)
    }

    init(error: Error) {
        self.result = .failure(error)
    }

    func execute(query: String) async throws -> Pokemon {
        try result.get()
    }
}
