//
//  SearchPokemon.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation

protocol SearchPokemonUseCaseProtocol {
    func execute(query: String) async throws -> Pokemon
}

struct SearchPokemon: SearchPokemonUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.repository = repository
    }

    func execute(query: String) async throws -> Pokemon {
        try await repository.searchPokemon(query: query.lowercased())
    }
}
