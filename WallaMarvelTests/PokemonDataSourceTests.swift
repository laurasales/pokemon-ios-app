//
//  PokemonDataSourceTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import XCTest
@testable import WallaMarvel

final class PokemonDataSourceTests: XCTestCase {

    // MARK: - getPokemonList

    func test_getPokemonList_mapsResponseToPokemon() async throws {
        let response = PokemonListResponseDTO(count: 2, results: [
            PokemonListItemDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            PokemonListItemDTO(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
        ])
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(listResponse: response))

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
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(listResponse: response))

        let pokemon = try await dataSource.getPokemonList(limit: 1, offset: 0)

        XCTAssertEqual(pokemon[0].name, "Mr-Mime")
    }

    func test_getPokemonList_filtersOutItemsWithInvalidURL() async throws {
        let response = PokemonListResponseDTO(count: 2, results: [
            PokemonListItemDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            PokemonListItemDTO(name: "invalid", url: "not-a-valid-pokemon-url")
        ])
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(listResponse: response))

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

    // MARK: - getPokemonDetail

    func test_getPokemonDetail_mapsResponseToPokemonDetail() async throws {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(detailResponse: .mock))

        let detail = try await dataSource.getPokemonDetail(id: 1)

        XCTAssertEqual(detail.id, 1)
        XCTAssertEqual(detail.name, "Bulbasaur")
        XCTAssertEqual(detail.slug, "bulbasaur")
        XCTAssertEqual(detail.height, 7)
        XCTAssertEqual(detail.weight, 69)
        XCTAssertEqual(detail.imageURL, URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"))
    }

    func test_getPokemonDetail_capitalizesNameAndTypes() async throws {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(detailResponse: .mock))

        let detail = try await dataSource.getPokemonDetail(id: 1)

        XCTAssertEqual(detail.name, "Bulbasaur")
        XCTAssertEqual(detail.types, ["Grass", "Poison"])
        XCTAssertEqual(detail.abilities, ["Overgrow", "Chlorophyll"])
    }

    func test_getPokemonDetail_preservesSlugAsRawName() async throws {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(detailResponse: .mock))

        let detail = try await dataSource.getPokemonDetail(id: 1)

        XCTAssertEqual(detail.slug, "bulbasaur")
    }

    func test_getPokemonDetail_mapsStats() async throws {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(detailResponse: .mock))

        let detail = try await dataSource.getPokemonDetail(id: 1)

        XCTAssertEqual(detail.stats.count, 1)
        XCTAssertEqual(detail.stats[0].name, "hp")
        XCTAssertEqual(detail.stats[0].value, 45)
    }

    func test_getPokemonDetail_propagatesAPIClientError() async {
        let dataSource = PokemonDataSource(apiClient: MockAPIClient(error: URLError(.notConnectedToInternet)))

        do {
            _ = try await dataSource.getPokemonDetail(id: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}

// MARK: - Mocks

private final class MockAPIClient: APIClientProtocol {
    private let listResult: Result<PokemonListResponseDTO, Error>
    private let detailResult: Result<PokemonDetailDTO, Error>

    init(listResponse: PokemonListResponseDTO) {
        self.listResult = .success(listResponse)
        self.detailResult = .failure(URLError(.unknown))
    }

    init(detailResponse: PokemonDetailDTO) {
        self.listResult = .failure(URLError(.unknown))
        self.detailResult = .success(detailResponse)
    }

    init(error: Error) {
        self.listResult = .failure(error)
        self.detailResult = .failure(error)
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponseDTO {
        try listResult.get()
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetailDTO {
        try detailResult.get()
    }
}

private extension PokemonDetailDTO {
    static let mock = PokemonDetailDTO(
        id: 1,
        name: "bulbasaur",
        height: 7,
        weight: 69,
        types: [TypeSlotDTO(type: NamedResourceDTO(name: "grass")), TypeSlotDTO(type: NamedResourceDTO(name: "poison"))],
        stats: [StatDTO(baseStat: 45, stat: NamedResourceDTO(name: "hp"))],
        abilities: [AbilitySlotDTO(ability: NamedResourceDTO(name: "overgrow")), AbilitySlotDTO(ability: NamedResourceDTO(name: "chlorophyll"))]
    )
}
