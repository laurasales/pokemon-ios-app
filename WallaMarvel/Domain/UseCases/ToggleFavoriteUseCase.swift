//
//  ToggleFavoriteUseCase.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

struct ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pokemon: Pokemon) {
        if repository.isFavorite(id: pokemon.id) {
            repository.removeFavorite(id: pokemon.id)
        } else {
            repository.addFavorite(pokemon)
        }
    }

    func isFavorite(id: Int) -> Bool {
        repository.isFavorite(id: id)
    }
}
