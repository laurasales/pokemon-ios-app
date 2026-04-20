//
//  PokemonDetailView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI
import Kingfisher

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(pokemonID: Int) {
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonID: pokemonID))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.detail {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView(detail: detail)
                        infoSection(detail: detail)
                        statsSection(stats: detail.stats)
                        abilitiesSection(abilities: detail.abilities)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.detail?.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.getDetail()
        }
    }

    private func headerView(detail: PokemonDetail) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 160, height: 160)
                KFImage(detail.imageURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
            }
            Text(String(format: "#%03d", detail.id))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(detail.types, id: \.self) { type in
                    Text(type)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func infoSection(detail: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Info")
                .font(.headline)
            HStack {
                infoCell(label: "Height", value: String(format: "%.1f m", Double(detail.height) / 10))
                Spacer()
                infoCell(label: "Weight", value: String(format: "%.1f kg", Double(detail.weight) / 10))
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func infoCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }

    private func statsSection(stats: [PokemonDetail.Stat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Stats")
                .font(.headline)
            ForEach(stats, id: \.name) { stat in
                HStack {
                    Text(stat.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    Text("\(stat.value)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 32, alignment: .trailing)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * min(CGFloat(stat.value) / 255, 1))
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
    }

    private func abilitiesSection(abilities: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Abilities")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(abilities, id: \.self) { ability in
                    Text(ability)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
