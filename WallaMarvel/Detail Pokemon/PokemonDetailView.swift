//
//  PokemonDetailView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(pokemonID: Int) {
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonID: pokemonID))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.detail {
                ScrollView {
                    VStack(spacing: 0) {
                        PokemonDetailHeaderView(detail: detail)
                        VStack(spacing: 24) {
                            PokemonInfoSectionView(detail: detail)
                            PokemonStatsSectionView(stats: detail.stats)
                            PokemonAbilitiesSectionView(abilities: detail.abilities)
                        }
                        .padding()
                        .padding(.bottom)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Unavailable",
                    systemImage: "exclamationmark.circle",
                    description: Text("This Pokémon's data could not be loaded.")
                )
            }
        }
        .navigationTitle(viewModel.detail?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getDetail()
        }
        .errorAlert(message: viewModel.errorMessage, onDismiss: viewModel.dismissError)
    }
}
