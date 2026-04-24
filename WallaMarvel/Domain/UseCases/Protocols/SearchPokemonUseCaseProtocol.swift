//
//  SearchPokemonUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol SearchPokemonUseCaseProtocol {
    func execute(query: String) async throws -> Pokemon
}
