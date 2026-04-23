//
//  String+PokemonType.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

extension String {
    var pokemonTypeSymbol: String {
        switch self.lowercased() {
        case "normal":   return "circle.fill"
        case "fire":     return "flame.fill"
        case "water":    return "drop.fill"
        case "electric": return "bolt.fill"
        case "grass":    return "leaf.fill"
        case "ice":      return "snowflake"
        case "fighting": return "hand.raised.fill"
        case "poison":   return "staroflife.fill"
        case "ground":   return "mountain.2.fill"
        case "flying":   return "wind"
        case "psychic":  return "eye.fill"
        case "bug":      return "ant.fill"
        case "rock":     return "diamond.fill"
        case "ghost":    return "moon.stars.fill"
        case "dragon":   return "lizard.fill"
        case "dark":     return "moon.fill"
        case "steel":    return "shield.fill"
        case "fairy":    return "sparkles"
        default:         return "questionmark.circle.fill"
        }
    }
}
