//
//  PokemonMapper.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

struct PokemonMapper {
    func toDomain(_ dto: PokemonDTO) -> Pokemon {
        Pokemon(id: dto.id, name: dto.name.capitalized, imageURL: dto.imageURL)
    }

    func toDomain(_ dto: PokemonDetailDTO) -> PokemonDetail {
        PokemonDetail(
            id: dto.id,
            name: dto.name.capitalized,
            slug: dto.name,
            imageURL: dto.imageURL,
            height: dto.height,
            weight: dto.weight,
            types: dto.types.map { $0.capitalized },
            stats: dto.stats.map { PokemonDetail.Stat(name: $0.name, value: $0.value) },
            abilities: dto.abilities.map { $0.capitalized }
        )
    }
}
