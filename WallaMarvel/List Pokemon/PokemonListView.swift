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
            List(viewModel.pokemon, id: \.id) { pokemon in
                PokemonRowView(pokemon: pokemon)
            }
            .navigationTitle(viewModel.title)
            .task {
                await viewModel.getPokemon()
            }
        }
    }
}
