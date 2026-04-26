//
//  PokemonDetail+Mock.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation
@testable import WallaMarvel

extension PokemonDetail {
    static let mock = PokemonDetail(
        id: 1,
        name: "Bulbasaur",
        slug: "bulbasaur",
        imageURL: URL(string: "https://example.com/1.png")!,
        height: 7,
        weight: 69,
        types: ["Grass", "Poison"],
        stats: [
            Stat(name: "hp", value: 45),
            Stat(name: "attack", value: 49),
        ],
        abilities: ["Overgrow", "Chlorophyll"]
    )
}
