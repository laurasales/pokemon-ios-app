//
//  GetPokemonTypesUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol GetPokemonTypesUseCaseProtocol {
    func execute() async throws -> [String]
}
