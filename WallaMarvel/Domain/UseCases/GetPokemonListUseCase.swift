//
//  GetPokemonListUseCase.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

struct GetPokemonListUseCase: GetPokemonListUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int, offset: Int) async throws -> [Pokemon] {
        try await repository.getPokemonList(limit: limit, offset: offset)
    }
}
