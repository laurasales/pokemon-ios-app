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
                    pokemonList
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
                await viewModel.getPokemon()
            }
        }
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
            ForEach(viewModel.pokemon, id: \.id) { pokemon in
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
