//
//  PokemonDetailContainerView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import SwiftUI

struct PokemonDetailContainerView: View {
    let pokemonID: Int
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        PokemonDetailView(viewModel: container.makePokemonDetailViewModel(pokemonID: pokemonID))
    }
}
