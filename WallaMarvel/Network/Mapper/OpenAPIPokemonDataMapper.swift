//
//  OpenAPIPokemonDataMapper.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

struct OpenAPIPokemonDataMapper {
    func toPokemonDTO(from resource: Components.Schemas.NamedResource) throws -> PokemonDTO {
        guard let id = SpriteURL.extractID(from: resource.url),
              let imageURL = SpriteURL.fromID(id) else {
            throw PokemonMappingError.missingData
        }
        return PokemonDTO(id: id, name: resource.name, imageURL: imageURL)
    }

    func toPokemonDTO(from pokemon: Components.Schemas.Pokemon) throws -> PokemonDTO {
        guard let spriteURL = pokemon.sprites.front_default,
              let imageURL = URL(string: spriteURL) else {
            throw PokemonMappingError.invalidSpriteURL
        }
        return PokemonDTO(id: pokemon.id, name: pokemon.name, imageURL: imageURL)
    }

    func toPokemonDetailDTO(from pokemon: Components.Schemas.Pokemon) throws -> PokemonDetailDTO {
        guard let spriteURL = pokemon.sprites.front_default,
              let imageURL = URL(string: spriteURL) else {
            throw PokemonMappingError.invalidSpriteURL
        }
        return PokemonDetailDTO(
            id: pokemon.id,
            name: pokemon.name,
            imageURL: imageURL,
            height: pokemon.height,
            weight: pokemon.weight,
            types: pokemon.types.map { $0._type.name },
            stats: pokemon.stats.map { PokemonDetailDTO.StatDTO(name: $0.stat.name, value: $0.base_stat) },
            abilities: pokemon.abilities.map { $0.ability.name }
        )
    }
}
