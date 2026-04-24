//
//  SearchPokemon.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation

struct SearchPokemonUseCase: SearchPokemonUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> Pokemon {
        try await repository.searchPokemon(query: query.lowercased())
    }
}
