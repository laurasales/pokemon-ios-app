//
//  PokemonStatsSectionView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import SwiftUI

struct PokemonStatsSectionView: View {
    let stats: [PokemonDetail.Stat]
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Stats")
                .font(.headline)
            ForEach(Array(stats.enumerated()), id: \.element.name) { index, stat in
                StatRowView(
                    label: stat.name.statAbbreviation,
                    value: stat.value,
                    maxValue: 255,
                    barColor: stat.value.statColor,
                    animate: animate,
                    animationDelay: Double(index) * 0.08
                )
            }
            let total = stats.reduce(0) { $0 + $1.value }
            StatRowView(
                label: "TOT",
                value: total,
                maxValue: 780,
                barColor: .accentColor,
                animate: animate,
                animationDelay: Double(stats.count) * 0.08
            )
        }
        .onAppear { animate = true }
    }
}

private struct StatRowView: View {
    let label: String
    let value: Int
    let maxValue: Int
    let barColor: Color
    let animate: Bool
    let animationDelay: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 32, alignment: .trailing)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: animate ? geometry.size.width * min(CGFloat(value) / CGFloat(maxValue), 1) : 0)
                        .animation(.easeOut(duration: 0.8).delay(animationDelay), value: animate)
                }
            }
            .frame(height: 8)
        }
    }
}

private extension String {
    var statAbbreviation: String {
        switch self.lowercased() {
        case "hp":              return "HP"
        case "attack":          return "ATK"
        case "defense":         return "DEF"
        case "special-attack":  return "SpA"
        case "special-defense": return "SpD"
        case "speed":           return "SPD"
        default:                return String(self.prefix(3)).uppercased()
        }
    }
}

private extension Int {
    var statColor: Color {
        switch self {
        case ..<50:    return Color(.systemRed)
        case 50..<80:  return Color(.systemOrange)
        case 80..<100: return Color(.systemYellow)
        default:       return Color(.systemGreen)
        }
    }
}
