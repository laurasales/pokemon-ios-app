//
//  PokemonTypeBadgeView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import SwiftUI

struct PokemonTypeBadgeView: View {
    let type: String
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.pokemonTypeSymbol)
                .font(.caption)
            Text(type.capitalized)
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.pokemonType(type).opacity(backgroundOpacity))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.pokemonType(type), lineWidth: isSelected ? 2 : 0)
        )
        .onTapGesture { onTap?() }
    }

    private var backgroundOpacity: Double {
        guard onTap != nil else { return 1.0 }
        return isSelected ? 1.0 : 0.5
    }
}
