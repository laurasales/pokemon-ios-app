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

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let response = try await client.listPokemon(query: .init(limit: limit, offset: offset))
        let body = try response.ok.body.json
        return try body.results.map { try mapper.toPokemon(from: $0) }
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        let response = try await client.getPokemon(path: .init(id: String(id)))
        let body = try response.ok.body.json
        return try mapper.toPokemonDetail(from: body)
    }

    func searchPokemon(query: String) async throws -> Pokemon {
        let response = try await client.getPokemon(path: .init(id: query))
        let body = try response.ok.body.json
        return try mapper.toPokemon(from: body)
    }

    func getPokemonByType(typeName: String) async throws -> [Pokemon] {
        let response = try await client.getPokemonType(path: .init(id: typeName))
        let body = try response.ok.body.json
        return try body.pokemon.compactMap { slot -> Pokemon? in
            guard let resource = slot.pokemon else { return nil }
            return try mapper.toPokemon(from: resource)
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
