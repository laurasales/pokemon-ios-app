//
//  PokemonDetailDTO.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation

struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeSlotDTO]
    let stats: [StatDTO]
    let abilities: [AbilitySlotDTO]

    struct TypeSlotDTO: Decodable {
        let type: NamedResourceDTO
    }

    struct StatDTO: Decodable {
        let baseStat: Int
        let stat: NamedResourceDTO

        enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case stat
        }
    }

    struct AbilitySlotDTO: Decodable {
        let ability: NamedResourceDTO
    }

    struct NamedResourceDTO: Decodable {
        let name: String
    }
}
