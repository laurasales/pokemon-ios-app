//
//  GetPokemonDetailUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol GetPokemonDetailUseCaseProtocol {
    func execute(id: Int) async throws -> PokemonDetail
}
