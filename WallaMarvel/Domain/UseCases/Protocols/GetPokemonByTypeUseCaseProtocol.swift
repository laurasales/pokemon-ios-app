//
//  GetPokemonByTypeUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol GetPokemonByTypeUseCaseProtocol {
    func execute(typeName: String) async throws -> [Pokemon]
}
