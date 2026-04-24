//
//  AccessibilitySnapshotTests.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 25/4/26.
//

import XCTest
import SwiftUI
import AccessibilitySnapshot
@testable import WallaMarvel

final class AccessibilitySnapshotTests: XCTestCase {

    // MARK: - PokemonRowView

    func test_pokemonRowView_default() {
        assertAccessibilitySnapshot(
            PokemonRowView(pokemon: .mockRow),
            size: CGSize(width: 375, height: 80)
        )
    }

    func test_pokemonRowView_favorited() {
        assertAccessibilitySnapshot(
            PokemonRowView(pokemon: .mockRow, isFavorite: true, onToggleFavorite: {}),
            size: CGSize(width: 375, height: 80)
        )
    }

    // MARK: - PokemonTypeBadgeView

    func test_typeBadgeView_displayMode() {
        assertAccessibilitySnapshot(
            PokemonTypeBadgeView(type: "fire"),
            size: CGSize(width: 120, height: 44)
        )
    }

    func test_typeBadgeView_filterUnselected() {
        assertAccessibilitySnapshot(
            PokemonTypeBadgeView(type: "fire", isSelected: false, onTap: {}),
            size: CGSize(width: 120, height: 44)
        )
    }

    func test_typeBadgeView_filterSelected() {
        assertAccessibilitySnapshot(
            PokemonTypeBadgeView(type: "fire", isSelected: true, onTap: {}),
            size: CGSize(width: 120, height: 44)
        )
    }

    // MARK: - PokemonInfoSectionView

    func test_pokemonInfoSectionView() {
        assertAccessibilitySnapshot(
            PokemonInfoSectionView(detail: .mock),
            size: CGSize(width: 375, height: 100)
        )
    }

    // MARK: - PokemonStatsSectionView

    func test_pokemonStatsSectionView() {
        assertAccessibilitySnapshot(
            PokemonStatsSectionView(stats: PokemonDetail.mock.stats),
            size: CGSize(width: 375, height: 160)
        )
    }

    // MARK: - PokemonAbilitiesSectionView

    func test_pokemonAbilitiesSectionView() {
        assertAccessibilitySnapshot(
            PokemonAbilitiesSectionView(abilities: PokemonDetail.mock.abilities),
            size: CGSize(width: 375, height: 120)
        )
    }

    // MARK: - Helpers

    private func assertAccessibilitySnapshot<V: View>(
        _ view: V,
        size: CGSize,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(origin: .zero, size: size)
        assertSnapshot(matching: controller, as: .accessibilityImage, file: file, testName: testName, line: line)
    }
}

private extension Pokemon {
    static let mockRow = Pokemon(
        id: 1,
        name: "Bulbasaur",
        imageURL: URL(string: "https://example.com/1.png")!
    )
}
