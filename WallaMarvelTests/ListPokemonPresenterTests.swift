//
//  ListPokemonPresenterTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

final class ListPokemonPresenterTests: XCTestCase {
    
    func test_screenTitle_returnsPokedex() {
        let presenter = ListPokemonPresenter(getPokemonListUseCase: MockGetPokemonListUseCase(pokemon: []))
        
        XCTAssertEqual(presenter.screenTitle(), "Pokédex")
    }
    
    func test_getPokemon_updatesUIWithPokemonOnSuccess() async throws {
        let expectedPokemon = [
            Pokemon(id: 1, name: "Bulbasaur", imageURL: URL(string: "https://example.com/1.png")!),
            Pokemon(id: 2, name: "Ivysaur", imageURL: URL(string: "https://example.com/2.png")!)
        ]
        let presenter = ListPokemonPresenter(getPokemonListUseCase: MockGetPokemonListUseCase(pokemon: expectedPokemon))
        let mockUI = MockListPokemonUI()
        presenter.ui = mockUI
        
        let expectation = XCTestExpectation(description: "UI updated with pokemon")
        mockUI.onUpdate = { _ in expectation.fulfill() }
        
        presenter.getPokemon()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(mockUI.receivedPokemon?.count, 2)
        XCTAssertEqual(mockUI.receivedPokemon?.first?.name, "Bulbasaur")
    }
    
    func test_getPokemon_doesNotUpdateUIOnError() async throws {
        let presenter = ListPokemonPresenter(
            getPokemonListUseCase: MockGetPokemonListUseCase(error: URLError(.notConnectedToInternet))
        )
        let mockUI = MockListPokemonUI()
        presenter.ui = mockUI
        
        presenter.getPokemon()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertNil(mockUI.receivedPokemon)
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

private final class MockListPokemonUI: ListPokemonUI {
    var receivedPokemon: [Pokemon]?
    var onUpdate: (([Pokemon]) -> Void)?
    
    func update(pokemon: [Pokemon]) {
        receivedPokemon = pokemon
        onUpdate?(pokemon)
    }
}
