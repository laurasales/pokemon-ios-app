//
//  GetPokemonByType.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

protocol GetPokemonByTypeUseCaseProtocol {
    func execute(typeName: String) async throws -> [Pokemon]
}

struct GetPokemonByType: GetPokemonByTypeUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(typeName: String) async throws -> [Pokemon] {
        try await repository.getPokemonByType(typeName: typeName)
    }
}
