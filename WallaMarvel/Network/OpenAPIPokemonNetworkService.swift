//
//  OpenAPIPokemonNetworkService.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class OpenAPIPokemonNetworkService: PokemonNetworkServiceProtocol {
    private let client: Client
    private let mapper: OpenAPIPokemonDataMapper

    init(mapper: OpenAPIPokemonDataMapper = OpenAPIPokemonDataMapper()) {
        client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.mapper = mapper
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [PokemonDTO] {
        let response = try await client.listPokemon(query: .init(limit: limit, offset: offset))
        let body = try response.ok.body.json
        return try body.results.map { try mapper.toPokemonDTO(from: $0) }
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetailDTO {
        let response = try await client.getPokemon(path: .init(id: String(id)))
        let body = try response.ok.body.json
        return try mapper.toPokemonDetailDTO(from: body)
    }

    func searchPokemon(query: String) async throws -> PokemonDTO {
        let response = try await client.getPokemon(path: .init(id: query))
        let body = try response.ok.body.json
        return try mapper.toPokemonDTO(from: body)
    }

    func getPokemonByType(typeName: String) async throws -> [PokemonDTO] {
        let response = try await client.getPokemonType(path: .init(id: typeName))
        let body = try response.ok.body.json
        return try body.pokemon.compactMap { slot -> PokemonDTO? in
            guard let resource = slot.pokemon else { return nil }
            return try mapper.toPokemonDTO(from: resource)
        }
    }

    func getPokemonTypes() async throws -> [String] {
        let response = try await client.listPokemonTypes()
        let body = try response.ok.body.json
        return body.results
            .map { $0.name }
            .filter { !["unknown", "shadow", "stellar"].contains($0) }
    }
}
