//
//  PokemonDetailHeaderView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonDetailHeaderView: View {
    let detail: PokemonDetail
    @State private var isFloating = false
    @StateObject private var soundPlayer = PokemonSoundPlayer()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                .accessibilityLabel("Number \(detail.id)")

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
                PokemonSpriteView(url: detail.imageURL, size: 160)
                    .offset(y: isFloating ? -10 : 0)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            isFloating = true
                        }
                    }
            }
            .accessibilityHidden(true)

            HStack(spacing: 8) {
                ForEach(detail.types, id: \.self) { type in
                    PokemonTypeBadgeView(type: type)
                }
            }

            Button {
                if soundPlayer.isPlaying {
                    soundPlayer.stop()
                } else {
                    soundPlayer.play(slug: detail.slug)
                }
            } label: {
                Image(systemName: soundPlayer.isPlaying ? "stop.circle.fill" : "speaker.wave.2.circle.fill")
                    .font(.title)
                    .foregroundStyle(primaryColor)
                    .symbolEffect(.bounce, value: soundPlayer.isPlaying)
            }
            .padding(.bottom, 12)
            .accessibilityLabel(soundPlayer.isPlaying ? "Stop \(detail.name)'s cry" : "Play \(detail.name)'s cry")
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }
}
