//
//  PokemonListView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = ListPokemonViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.pokemon.isEmpty && !viewModel.isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isSearching {
                    searchContent
                } else {
                    mainContent
                }
            }
            .navigationTitle(viewModel.title)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Name or number")
            .onSubmit(of: .search) {
                Task { await viewModel.searchPokemon() }
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                if newValue.isEmpty { viewModel.clearSearch() }
            }
            .task {
                async let types: () = viewModel.loadTypes()
                async let pokemon: () = viewModel.getPokemon()
                _ = await (types, pokemon)
                viewModel.loadFavorites()
            }
            .errorAlert(message: viewModel.errorMessage, onDismiss: viewModel.dismissError)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            typeFilterBar
            if viewModel.showingFavoritesOnly && viewModel.favorites.isEmpty {
                emptyFavoritesView
            } else if viewModel.isTypeFilterLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.isLoading && viewModel.selectedType != nil && viewModel.filteredPokemon.isEmpty {
                ContentUnavailableView(
                    "No Pokémon found",
                    systemImage: "questionmark.circle",
                    description: Text("No Pokémon of this type are available.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                pokemonList
            }
        }
    }

    private var emptyFavoritesView: some View {
        ContentUnavailableView(
            "No favourites yet",
            systemImage: "heart.slash",
            description: Text("Tap the heart on any Pokémon to save it here.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                PokemonTypeBadgeView(
                    type: "favorites",
                    isSelected: viewModel.showingFavoritesOnly,
                    onTap: { viewModel.toggleShowFavoritesOnly() }
                )
                ForEach(viewModel.pokemonTypes, id: \.self) { type in
                    PokemonTypeBadgeView(
                        type: type,
                        isSelected: viewModel.selectedType == type,
                        onTap: { Task { await viewModel.selectType(type) } }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var searchContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.searchNotFound {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else if let result = viewModel.searchResult {
            List {
                NavigationLink(destination: PokemonDetailView(pokemonID: result.id)) {
                    PokemonRowView(pokemon: result)
                }
            }
            .listStyle(.plain)
        } else {
            ContentUnavailableView.search(text: viewModel.searchText)
        }
    }

    private var pokemonList: some View {
        List {
            ForEach(viewModel.displayedPokemon, id: \.id) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemonID: pokemon.id)) {
                    PokemonRowView(
                        pokemon: pokemon,
                        isFavorite: viewModel.isFavorite(pokemon),
                        onToggleFavorite: { viewModel.toggleFavorite(pokemon) }
                    )
                }
                .task {
                    if !viewModel.showingFavoritesOnly {
                        await viewModel.loadMoreIfNeeded(currentPokemon: pokemon)
                    }
                }
            }
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            if viewModel.showingFavoritesOnly {
                viewModel.loadFavorites()
            } else if let type = viewModel.selectedType {
                await viewModel.refreshFilteredPokemon(typeName: type)
            } else {
                await viewModel.getPokemon()
            }
        }
    }
}
