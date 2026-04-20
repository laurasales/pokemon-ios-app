//
//  PokemonDataSource.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

protocol PokemonDataSourceProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
    func getPokemonDetail(id: Int) async throws -> PokemonDetail
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
    
    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        let dto = try await apiClient.getPokemonDetail(id: id)
        guard let imageURL = URL(string: "\(Constant.spriteBaseURL)/\(dto.id).png") else {
            throw URLError(.badURL)
        }
        return PokemonDetail(
            id: dto.id,
            name: dto.name.capitalized,
            imageURL: imageURL,
            height: dto.height,
            weight: dto.weight,
            types: dto.types.map { $0.type.name.capitalized },
            stats: dto.stats.map { PokemonDetail.Stat(name: $0.stat.name, value: $0.baseStat) },
            abilities: dto.abilities.map { $0.ability.name.capitalized }
        )
    }

    private func extractID(from url: String) -> Int? {
        // URL format: https://pokeapi.co/api/v2/pokemon/{id}/
        url.split(separator: "/").last.flatMap { Int($0) }
    }
}
