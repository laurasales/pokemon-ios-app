//
//  PokemonSpriteView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Kingfisher
import SwiftUI

struct PokemonSpriteView: View {
    let url: URL
    let size: CGFloat

    @State private var loadFailed = false
    @State private var isLoaded = false

    var body: some View {
        ZStack {
            if loadFailed {
                failurePlaceholder
            } else if !isLoaded {
                loadingPlaceholder
            }
            if !loadFailed {
                KFImage(url)
                    .onSuccess { _ in
                        withAnimation(.easeIn(duration: 0.2)) { isLoaded = true }
                    }
                    .onFailure { _ in loadFailed = true }
                    .resizable()
                    .scaledToFit()
                    .opacity(isLoaded ? 1 : 0)
            }
        }
        .frame(width: size, height: size)
    }

    private var loadingPlaceholder: some View {
        ProgressView()
            .tint(.secondary)
            .scaleEffect(size > 80 ? 1.2 : 0.8)
            .frame(width: size, height: size)
    }

    private var failurePlaceholder: some View {
        Image(systemName: "questionmark")
            .font(.system(size: size * 0.35, weight: .ultraLight))
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
    }
}
