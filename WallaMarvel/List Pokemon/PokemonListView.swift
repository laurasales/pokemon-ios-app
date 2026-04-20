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
                if viewModel.isLoading && viewModel.pokemon.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
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
            .navigationTitle(viewModel.title)
            .task {
                await viewModel.getPokemon()
            }
        }
    }
}
