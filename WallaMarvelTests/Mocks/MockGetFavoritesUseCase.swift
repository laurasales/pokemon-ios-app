//
//  MockGetFavoritesUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 24/4/26.
//

@testable import WallaMarvel

final class MockGetFavoritesUseCase: GetFavoritesUseCaseProtocol {
    private let favorites: [Pokemon]

    init(favorites: [Pokemon] = []) {
        self.favorites = favorites
    }

    func execute() -> [Pokemon] {
        favorites
    }
}
