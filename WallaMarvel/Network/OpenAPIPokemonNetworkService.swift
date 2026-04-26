//
//  OpenAPIPokemonNetworkService.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import os

final class OpenAPIPokemonNetworkService: PokemonNetworkServiceProtocol {
    private let client: Client
    private let mapper: OpenAPIPokemonDataMapper

    init(mapper: OpenAPIPokemonDataMapper = OpenAPIPokemonDataMapper()) {
        client = Client(
            serverURL: Self.makeServerURL(),
            transport: URLSessionTransport()
        )
        self.mapper = mapper
    }

    private static func makeServerURL() -> URL {
        guard let url = try? Servers.Server1.url() else {
            preconditionFailure("Invalid server URL in OpenAPI spec")
        }
        return url
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [PokemonDTO] {
        do {
            let response = try await client.listPokemon(query: .init(limit: limit, offset: offset))
            let body = try response.ok.body.json
            return try body.results.map { try mapper.toPokemonDTO(from: $0) }
        } catch {
            Logger.network.error("getPokemonList failed — limit: \(limit), offset: \(offset), error: \(error)")
            throw error
        }
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetailDTO {
        do {
            let response = try await client.getPokemon(path: .init(id: String(id)))
            let body = try response.ok.body.json
            return try mapper.toPokemonDetailDTO(from: body)
        } catch {
            Logger.network.error("getPokemonDetail failed — id: \(id), error: \(error)")
            throw error
        }
    }

    func searchPokemon(query: String) async throws -> PokemonDTO {
        do {
            let response = try await client.getPokemon(path: .init(id: query))
            let body = try response.ok.body.json
            return try mapper.toPokemonDTO(from: body)
        } catch {
            Logger.network.error("searchPokemon failed — query: \(query), error: \(error)")
            throw error
        }
    }

    func getPokemonByType(typeName: String) async throws -> [PokemonDTO] {
        do {
            let response = try await client.getPokemonType(path: .init(id: typeName))
            let body = try response.ok.body.json
            return try body.pokemon.compactMap { slot -> PokemonDTO? in
                guard let resource = slot.pokemon else { return nil }
                return try mapper.toPokemonDTO(from: resource)
            }
        } catch {
            Logger.network.error("getPokemonByType failed — type: \(typeName), error: \(error)")
            throw error
        }
    }

    func getPokemonTypes() async throws -> [String] {
        do {
            let response = try await client.listPokemonTypes()
            let body = try response.ok.body.json
            return body.results
                .map(\.name)
                .filter { !["unknown", "shadow", "stellar"].contains($0) }
        } catch {
            Logger.network.error("getPokemonTypes failed — error: \(error)")
            throw error
        }
    }
}
