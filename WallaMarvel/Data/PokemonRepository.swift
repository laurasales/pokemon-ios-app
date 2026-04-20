//
//  PokemonRepository.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

final class PokemonRepository: PokemonRepositoryProtocol {
    private let dataSource: PokemonDataSourceProtocol

    init(dataSource: PokemonDataSourceProtocol = PokemonDataSource()) {
        self.dataSource = dataSource
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        try await dataSource.getPokemonList(limit: limit, offset: offset)
    }
}
