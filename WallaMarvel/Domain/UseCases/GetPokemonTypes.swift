//
//  GetPokemonTypes.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

protocol GetPokemonTypesUseCaseProtocol {
    func execute() async throws -> [String]
}

struct GetPokemonTypes: GetPokemonTypesUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [String] {
        try await repository.getPokemonTypes()
    }
}
