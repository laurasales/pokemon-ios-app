//
//  PokemonMapperHelpers.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

enum PokemonMappingError: Error {
    case missingData
    case invalidSpriteURL
}

enum SpriteURL {
    static let baseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"

    static func fromID(_ id: Int) -> URL? {
        URL(string: "\(baseURL)/\(id).png")
    }

    static func extractID(from url: String) -> Int? {
        url.split(separator: "/").last.flatMap { Int($0) }
    }
}
