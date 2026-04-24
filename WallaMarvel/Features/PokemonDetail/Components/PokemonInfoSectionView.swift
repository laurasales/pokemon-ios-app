//
//  PokemonInfoSectionView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonInfoSectionView: View {
    let detail: PokemonDetail

    var body: some View {
        HStack {
            InfoCellView(
                label: "Height",
                value: String(format: "%.1f m", Double(detail.height) / 10),
                symbol: "ruler"
            )
            Divider().frame(height: 40)
            InfoCellView(
                label: "Weight",
                value: String(format: "%.1f kg", Double(detail.weight) / 10),
                symbol: "scalemass.fill"
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct InfoCellView: View {
    let label: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}
