//
//  PokemonDataSource.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

protocol PokemonDataSourceProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
}

final class PokemonDataSource: PokemonDataSourceProtocol {
    private enum Constant {
        static let spriteBaseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"
    }

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let response = try await apiClient.getPokemonList(limit: limit, offset: offset)
        return response.results.compactMap { item in
            guard let id = extractID(from: item.url),
                  let imageURL = URL(string: "\(Constant.spriteBaseURL)/\(id).png") else {
                return nil
            }
            return Pokemon(id: id, name: item.name.capitalized, imageURL: imageURL)
        }
    }

    private func extractID(from url: String) -> Int? {
        // URL format: https://pokeapi.co/api/v2/pokemon/{id}/
        url.split(separator: "/").last.flatMap { Int($0) }
    }
}
