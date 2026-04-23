//
//  Color+PokemonType.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

extension Color {
    static func pokemonType(_ type: String) -> Color {
        switch type.lowercased() {
        case "normal":   return Color(red: 0.66, green: 0.65, blue: 0.47)
        case "fire":     return Color(red: 0.94, green: 0.50, blue: 0.19)
        case "water":    return Color(red: 0.41, green: 0.56, blue: 0.94)
        case "electric": return Color(red: 0.97, green: 0.82, blue: 0.19)
        case "grass":    return Color(red: 0.47, green: 0.78, blue: 0.31)
        case "ice":      return Color(red: 0.60, green: 0.85, blue: 0.85)
        case "fighting": return Color(red: 0.75, green: 0.19, blue: 0.16)
        case "poison":   return Color(red: 0.63, green: 0.25, blue: 0.63)
        case "ground":   return Color(red: 0.88, green: 0.75, blue: 0.42)
        case "flying":   return Color(red: 0.66, green: 0.56, blue: 0.94)
        case "psychic":  return Color(red: 0.97, green: 0.35, blue: 0.53)
        case "bug":      return Color(red: 0.66, green: 0.72, blue: 0.13)
        case "rock":     return Color(red: 0.72, green: 0.63, blue: 0.22)
        case "ghost":    return Color(red: 0.44, green: 0.35, blue: 0.60)
        case "dragon":   return Color(red: 0.44, green: 0.22, blue: 0.97)
        case "dark":     return Color(red: 0.44, green: 0.36, blue: 0.30)
        case "steel":    return Color(red: 0.72, green: 0.72, blue: 0.82)
        case "fairy":    return Color(red: 0.93, green: 0.60, blue: 0.68)
        default:         return .gray
        }
    }
}
