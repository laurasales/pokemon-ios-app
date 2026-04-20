//
//  PokemonListResponseDTO.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

struct PokemonListResponseDTO: Decodable {
    let count: Int
    let results: [PokemonListItemDTO]
}
