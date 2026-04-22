//
//  PokemonDataMapper.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 22/4/26.
//

import Foundation
import PokemonAPI

struct PokemonDataMapper {
    private enum Constant {
        static let spriteBaseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"
    }

    func toPokemon(from resource: PKMAPIResource<PKMPokemon>) throws -> Pokemon {
        guard let name = resource.name,
              let url = resource.url,
              let id = extractID(from: url),
              let imageURL = URL(string: "\(Constant.spriteBaseURL)/\(id).png") else {
            throw URLError(.badURL)
        }
        return Pokemon(id: id, name: name.capitalized, imageURL: imageURL)
    }

    func toPokemon(from pokemon: PKMPokemon) throws -> Pokemon {
        guard let id = pokemon.id,
              let name = pokemon.name,
              let spriteString = pokemon.sprites?.frontDefault,
              let imageURL = URL(string: spriteString) else {
            throw URLError(.badServerResponse)
        }
        return Pokemon(id: id, name: name.capitalized, imageURL: imageURL)
    }

    func toDomainDetail(from pokemon: PKMPokemon) throws -> PokemonDetail {
        guard let id = pokemon.id,
              let name = pokemon.name,
              let spriteString = pokemon.sprites?.frontDefault,
              let imageURL = URL(string: spriteString) else {
            throw URLError(.badServerResponse)
        }
        return PokemonDetail(
            id: id,
            name: name.capitalized,
            slug: name,
            imageURL: imageURL,
            height: pokemon.height ?? 0,
            weight: pokemon.weight ?? 0,
            types: (pokemon.types ?? []).compactMap { $0.`type`?.name?.capitalized },
            stats: (pokemon.stats ?? []).compactMap { stat in
                guard let name = stat.stat?.name, let value = stat.baseStat else { return nil }
                return PokemonDetail.Stat(name: name, value: value)
            },
            abilities: (pokemon.abilities ?? []).compactMap { $0.ability?.name?.capitalized }
        )
    }

    private func extractID(from url: String) -> Int? {
        url.split(separator: "/").last.flatMap { Int($0) }
    }
}
