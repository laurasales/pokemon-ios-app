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
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 72, height: 72)
                PokemonSpriteView(url: pokemon.imageURL, size: 60)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("#\(pokemon.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(pokemon.name)
                    .font(.headline)
            }
            Spacer()
            if let onToggleFavorite {
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : Color(.systemGray3))
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }
}
