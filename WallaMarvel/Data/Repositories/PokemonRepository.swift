//
//  PokemonRepository.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

final class PokemonRepository: PokemonRepositoryProtocol {
    private let networkService: PokemonNetworkServiceProtocol
    private let mapper: PokemonMapper

    init(networkService: PokemonNetworkServiceProtocol, mapper: PokemonMapper = PokemonMapper()) {
        self.networkService = networkService
        self.mapper = mapper
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let dtos = try await networkService.getPokemonList(limit: limit, offset: offset)
        return dtos.map { mapper.toDomain($0) }
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        let dto = try await networkService.getPokemonDetail(id: id)
        return mapper.toDomain(dto)
    }

    func searchPokemon(query: String) async throws -> Pokemon {
        let dto = try await networkService.searchPokemon(query: query)
        return mapper.toDomain(dto)
    }

    func getPokemonByType(typeName: String) async throws -> [Pokemon] {
        let dtos = try await networkService.getPokemonByType(typeName: typeName)
        return dtos.map { mapper.toDomain($0) }
    }

    func getPokemonTypes() async throws -> [String] {
        try await networkService.getPokemonTypes()
    }
}
