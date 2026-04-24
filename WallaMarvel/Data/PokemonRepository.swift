//
//  PokemonRepository.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

final class PokemonRepository: PokemonRepositoryProtocol {
    private let networkService: PokemonNetworkServiceProtocol

    init(networkService: PokemonNetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        try await networkService.getPokemonList(limit: limit, offset: offset)
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        try await networkService.getPokemonDetail(id: id)
    }

    func searchPokemon(query: String) async throws -> Pokemon {
        try await networkService.searchPokemon(query: query)
    }

    func getPokemonByType(typeName: String) async throws -> [Pokemon] {
        try await networkService.getPokemonByType(typeName: typeName)
    }

    func getPokemonTypes() async throws -> [String] {
        try await networkService.getPokemonTypes()
    }
}
