//
//  PokemonDTO.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

struct PokemonDTO {
    let id: Int
    let name: String
    let imageURL: URL
}

struct PokemonDetailDTO {
    let id: Int
    let name: String
    let imageURL: URL
    let height: Int
    let weight: Int
    let types: [String]
    let stats: [StatDTO]
    let abilities: [String]

    struct StatDTO {
        let name: String
        let value: Int
    }
}
