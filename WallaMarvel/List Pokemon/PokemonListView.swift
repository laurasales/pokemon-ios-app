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
                    VStack(spacing: 0) {
                        typeFilterBar
                        pokemonList
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .searchable(text: $viewModel.searchText, prompt: "Name or number")
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
            }
        }
    }

    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.pokemonTypes, id: \.self) { type in
                    TypeChipView(
                        type: type,
                        isSelected: viewModel.selectedType == type
                    ) {
                        Task { await viewModel.selectType(type) }
                    }
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
        let displayed = viewModel.selectedType != nil ? viewModel.filteredPokemon : viewModel.pokemon
        return List {
            ForEach(displayed, id: \.id) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemonID: pokemon.id)) {
                    PokemonRowView(pokemon: pokemon)
                }
                .task {
                    await viewModel.loadMoreIfNeeded(currentPokemon: pokemon)
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
            await viewModel.getPokemon()
        }
    }
}

private struct TypeChipView: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.pokemonType(type).opacity(isSelected ? 1.0 : 0.5))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.pokemonType(type), lineWidth: isSelected ? 2 : 0)
                )
        }
        .buttonStyle(.plain)
    }
}
