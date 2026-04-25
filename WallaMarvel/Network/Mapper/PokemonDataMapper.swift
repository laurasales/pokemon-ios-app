//
//  PokemonDataMapper.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation
import PokemonAPI

struct PokemonDataMapper {
    func toPokemonDTO(from resource: PKMAPIResource<PKMPokemon>) throws -> PokemonDTO {
        guard let name = resource.name,
              let url = resource.url,
              let id = SpriteURL.extractID(from: url),
              let imageURL = SpriteURL.fromID(id)
        else {
            throw PokemonMappingError.missingData
        }
        return PokemonDTO(id: id, name: name, imageURL: imageURL)
    }

    func toPokemonDTO(from pokemon: PKMPokemon) throws -> PokemonDTO {
        guard let id = pokemon.id,
              let name = pokemon.name,
              let spriteString = pokemon.sprites?.frontDefault,
              let imageURL = URL(string: spriteString)
        else {
            throw PokemonMappingError.missingData
        }
        return PokemonDTO(id: id, name: name, imageURL: imageURL)
    }

    func toPokemonDetailDTO(from pokemon: PKMPokemon) throws -> PokemonDetailDTO {
        guard let id = pokemon.id,
              let name = pokemon.name,
              let spriteString = pokemon.sprites?.frontDefault,
              let imageURL = URL(string: spriteString)
        else {
            throw PokemonMappingError.missingData
        }
        return PokemonDetailDTO(
            id: id,
            name: name,
            imageURL: imageURL,
            height: pokemon.height ?? 0,
            weight: pokemon.weight ?? 0,
            types: (pokemon.types ?? []).compactMap { $0.type?.name },
            stats: (pokemon.stats ?? []).compactMap { stat in
                guard let name = stat.stat?.name, let value = stat.baseStat else { return nil }
                return PokemonDetailDTO.StatDTO(name: name, value: value)
            },
            abilities: (pokemon.abilities ?? []).compactMap { $0.ability?.name }
        )
    }
}
