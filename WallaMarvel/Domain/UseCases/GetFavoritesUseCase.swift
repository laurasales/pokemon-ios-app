//
//  GetFavorites.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

struct GetFavoritesUseCase: GetFavoritesUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [Pokemon] {
        repository.getFavorites()
    }
}
