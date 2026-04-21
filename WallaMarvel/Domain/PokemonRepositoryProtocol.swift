//
//  PokemonRepositoryProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
    func getPokemonDetail(id: Int) async throws -> PokemonDetail
}
