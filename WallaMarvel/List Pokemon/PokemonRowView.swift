//
//  PokemonRowView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI
import Kingfisher

struct PokemonRowView: View {
    let pokemon: Pokemon
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(pokemon.imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(pokemon.name)
                .font(.body)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
