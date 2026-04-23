//
//  PokemonNetworkServiceProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation

protocol PokemonNetworkServiceProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
    func getPokemonDetail(id: Int) async throws -> PokemonDetail
    func searchPokemon(query: String) async throws -> Pokemon
    func getPokemonByType(typeName: String) async throws -> [Pokemon]
    func getPokemonTypes() async throws -> [String]
}
