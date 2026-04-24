//
//  PokemonNetworkServiceProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation

protocol PokemonNetworkServiceProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> [PokemonDTO]
    func getPokemonDetail(id: Int) async throws -> PokemonDetailDTO
    func searchPokemon(query: String) async throws -> PokemonDTO
    func getPokemonByType(typeName: String) async throws -> [PokemonDTO]
    func getPokemonTypes() async throws -> [String]
}
