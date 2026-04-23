//
//  OpenAPIPokemonDataMapper.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

struct OpenAPIPokemonDataMapper {
    func toPokemon(from resource: Components.Schemas.NamedResource) throws -> Pokemon {
        guard let id = SpriteURL.extractID(from: resource.url),
              let imageURL = SpriteURL.fromID(id) else {
            throw PokemonMappingError.missingData
        }
        return Pokemon(id: id, name: resource.name.capitalized, imageURL: imageURL)
    }

    func toPokemon(from pokemon: Components.Schemas.Pokemon) throws -> Pokemon {
        guard let spriteURL = pokemon.sprites.front_default,
              let imageURL = URL(string: spriteURL) else {
            throw PokemonMappingError.invalidSpriteURL
        }
        return Pokemon(id: pokemon.id, name: pokemon.name.capitalized, imageURL: imageURL)
    }

    func toPokemonDetail(from pokemon: Components.Schemas.Pokemon) throws -> PokemonDetail {
        guard let spriteURL = pokemon.sprites.front_default,
              let imageURL = URL(string: spriteURL) else {
            throw PokemonMappingError.invalidSpriteURL
        }
        return PokemonDetail(
            id: pokemon.id,
            name: pokemon.name.capitalized,
            slug: pokemon.name,
            imageURL: imageURL,
            height: pokemon.height,
            weight: pokemon.weight,
            types: pokemon.types.map { $0._type.name.capitalized },
            stats: pokemon.stats.map { PokemonDetail.Stat(name: $0.stat.name, value: $0.base_stat) },
            abilities: pokemon.abilities.map { $0.ability.name.capitalized }
        )
    }
}
