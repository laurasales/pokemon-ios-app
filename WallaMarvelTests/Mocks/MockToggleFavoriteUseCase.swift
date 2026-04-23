//
//  MockToggleFavoriteUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 24/4/26.
//

@testable import WallaMarvel

final class MockToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private(set) var toggledPokemon: Pokemon?
    var favoriteIDs: Set<Int>

    init(favoriteIDs: Set<Int> = []) {
        self.favoriteIDs = favoriteIDs
    }

    func execute(pokemon: Pokemon) {
        toggledPokemon = pokemon
        if favoriteIDs.contains(pokemon.id) {
            favoriteIDs.remove(pokemon.id)
        } else {
            favoriteIDs.insert(pokemon.id)
        }
    }

    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }
}
