//
//  PokemonDetailHeaderView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI
import Kingfisher

struct PokemonDetailHeaderView: View {
    let detail: PokemonDetail
    @State private var isFloating = false

    private var primaryColor: Color {
        detail.types.first.map { Color.pokemonType($0) } ?? .gray
    }

    private var secondaryColor: Color {
        detail.types.count > 1 ? Color.pokemonType(detail.types[1]) : primaryColor.opacity(0.5)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "#%03d", detail.id))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.4), secondaryColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                KFImage(detail.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .offset(y: isFloating ? -10 : 0)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            isFloating = true
                        }
                    }
            }

            HStack(spacing: 8) {
                ForEach(detail.types, id: \.self) { type in
                    PokemonTypeBadgeView(type: type)
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }
}

struct PokemonTypeBadgeView: View {
    let type: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.typeSymbol)
                .font(.caption)
            Text(type)
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color.pokemonType(type))
        .clipShape(Capsule())
    }
}

private extension String {
    var typeSymbol: String {
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
