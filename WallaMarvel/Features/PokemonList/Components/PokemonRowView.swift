//
//  PokemonRowView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: Pokemon
    var isFavorite: Bool = false
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 16) {
            avatar
            info
            Spacer()
            heartButton
        }
        .padding(.vertical, 6)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 72, height: 72)
            PokemonSpriteView(url: pokemon.imageURL, size: 60)
        }
        .accessibilityHidden(true)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("#\(pokemon.id)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(pokemon.name)
                .font(.headline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pokemon.name.capitalized), number \(pokemon.id)")
    }

    @ViewBuilder
    private var heartButton: some View {
        if let onToggleFavorite {
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : Color(.systemGray3))
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Remove \(pokemon.name) from favourites" : "Add \(pokemon.name) to favourites")
        }
    }
}
