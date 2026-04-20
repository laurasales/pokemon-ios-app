//
//  PokemonDataSourceTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

final class PokemonDataSourceTests: XCTestCase {
    
    func test_getPokemonList_mapsResponseToPokemon() async throws {
        let response = PokemonListResponseDTO(count: 2, results: [
            PokemonListItemDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            PokemonListItemDTO(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
        ])
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(response: response))
        
        let pokemon = try await dataSource.getPokemonList(limit: 2, offset: 0)
        
        XCTAssertEqual(pokemon.count, 2)
        XCTAssertEqual(pokemon[0].id, 1)
        XCTAssertEqual(pokemon[0].name, "Bulbasaur")
        XCTAssertEqual(pokemon[0].imageURL, URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"))
        XCTAssertEqual(pokemon[1].id, 2)
        XCTAssertEqual(pokemon[1].name, "Ivysaur")
    }
    
    func test_getPokemonList_capitalizesName() async throws {
        let response = PokemonListResponseDTO(count: 1, results: [
            PokemonListItemDTO(name: "mr-mime", url: "https://pokeapi.co/api/v2/pokemon/122/")
        ])
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(response: response))
        
        let pokemon = try await dataSource.getPokemonList(limit: 1, offset: 0)
        
        XCTAssertEqual(pokemon[0].name, "Mr-Mime")
    }
    
    func test_getPokemonList_filtersOutItemsWithInvalidURL() async throws {
        let response = PokemonListResponseDTO(count: 2, results: [
            PokemonListItemDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            PokemonListItemDTO(name: "invalid", url: "not-a-valid-pokemon-url")
        ])
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(response: response))
        
        let pokemon = try await dataSource.getPokemonList(limit: 2, offset: 0)
        
        XCTAssertEqual(pokemon.count, 1)
        XCTAssertEqual(pokemon[0].name, "Bulbasaur")
    }
    
    func test_getPokemonList_propagatesAPIClientError() async {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(error: URLError(.notConnectedToInternet)))
        
        do {
            _ = try await dataSource.getPokemonList(limit: 20, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}

// MARK: - Mocks

private final class MockAPIClient: APIClientProtocol {
    private let result: Result<PokemonListResponseDTO, Error>
    
    init(response: PokemonListResponseDTO) {
        self.result = .success(response)
    }
    
    init(error: Error) {
        self.result = .failure(error)
    }
    
    func getPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponseDTO {
        try result.get()
    }
}
