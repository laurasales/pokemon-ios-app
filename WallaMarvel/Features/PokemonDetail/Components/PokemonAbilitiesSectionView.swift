//
//  PokemonAbilitiesSectionView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonAbilitiesSectionView: View {
    let abilities: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Abilities")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
                ForEach(abilities, id: \.self) { ability in
                    Text(ability)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
