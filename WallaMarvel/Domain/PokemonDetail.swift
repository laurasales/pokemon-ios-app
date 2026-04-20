//
//  PokemonDetail.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation

struct PokemonDetail {
    let id: Int
    let name: String
    let imageURL: URL
    let height: Int
    let weight: Int
    let types: [String]
    let stats: [Stat]
    let abilities: [String]

    struct Stat {
        let name: String
        let value: Int
    }
}
