//
//  String+PokemonType.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

extension String {
    var pokemonTypeSymbol: String {
        switch lowercased() {
        case "normal": "circle.fill"
        case "fire": "flame.fill"
        case "water": "drop.fill"
        case "electric": "bolt.fill"
        case "grass": "leaf.fill"
        case "ice": "snowflake"
        case "fighting": "hand.raised.fill"
        case "poison": "staroflife.fill"
        case "ground": "mountain.2.fill"
        case "flying": "wind"
        case "psychic": "eye.fill"
        case "bug": "ant.fill"
        case "rock": "diamond.fill"
        case "ghost": "moon.stars.fill"
        case "dragon": "lizard.fill"
        case "dark": "moon.fill"
        case "steel": "shield.fill"
        case "fairy": "sparkles"
        case "favorites": "heart.fill"
        default: "questionmark.circle.fill"
        }
    }
}
