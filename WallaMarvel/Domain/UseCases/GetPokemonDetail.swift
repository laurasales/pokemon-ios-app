//
//  GetPokemonDetail.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation

protocol GetPokemonDetailUseCaseProtocol {
    func execute(id: Int) async throws -> PokemonDetail
}

struct GetPokemonDetail: GetPokemonDetailUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> PokemonDetail {
        try await repository.getPokemonDetail(id: id)
    }
}
