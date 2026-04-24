//
//  GetPokemonListUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol GetPokemonListUseCaseProtocol {
    func execute(limit: Int, offset: Int) async throws -> [Pokemon]
}
