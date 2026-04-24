//
//  PokemonDetailView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(viewModel: PokemonDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.detail {
                detailContent(detail)
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
        .toolbar { favoriteButton }
        .task { await viewModel.getDetail() }
        .errorAlert(message: viewModel.errorMessage, onDismiss: viewModel.dismissError)
    }

    private func detailContent(_ detail: PokemonDetail) -> some View {
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
    }

    @ToolbarContentBuilder
    private var favoriteButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(viewModel.isFavorite ? .red : .primary)
            }
            .disabled(viewModel.detail == nil)
        }
    }
}
