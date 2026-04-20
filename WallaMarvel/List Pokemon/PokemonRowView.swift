//
//  PokemonRowView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI
import Kingfisher

struct PokemonRowView: View {
    let pokemon: Pokemon

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 72, height: 72)
                KFImage(pokemon.imageURL)
                    .placeholder {
                        ProgressView()
                            .frame(width: 72, height: 72)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "#%03d", pokemon.id))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(pokemon.name)
                    .font(.headline)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
