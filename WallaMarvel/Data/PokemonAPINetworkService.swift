//
//  PokemonAPINetworkService.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation
import PokemonAPI

final class PokemonAPINetworkService: PokemonNetworkServiceProtocol {
    private let api: PokemonAPI
    private let mapper: PokemonDataMapper

    init(api: PokemonAPI = PokemonAPI(), mapper: PokemonDataMapper = PokemonDataMapper()) {
        self.api = api
        self.mapper = mapper
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let paged = try await api.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: limit, offset: offset)
        )
        return (paged.results ?? []).compactMap { try? mapper.toPokemon(from: $0) }
    }

    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        let pokemon = try await api.pokemonService.fetchPokemon(id)
        return try mapper.toDomainDetail(from: pokemon)
    }

    func searchPokemon(query: String) async throws -> Pokemon {
        let pokemon = try await api.pokemonService.fetchPokemon(query)
        return try mapper.toPokemon(from: pokemon)
    }
}
