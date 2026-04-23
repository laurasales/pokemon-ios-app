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
            }
        }
    }

    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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

