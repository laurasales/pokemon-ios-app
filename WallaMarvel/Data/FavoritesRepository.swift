//
//  FavoritesRepository.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation
import RealmSwift

final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let realm: Realm

    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }

    func getFavorites() -> [Pokemon] {
        realm.objects(FavoritePokemon.self).compactMap { $0.toDomain() }
    }

    func isFavorite(id: Int) -> Bool {
        realm.object(ofType: FavoritePokemon.self, forPrimaryKey: id) != nil
    }

    func addFavorite(_ pokemon: Pokemon) {
        guard !isFavorite(id: pokemon.id) else { return }
        let object = FavoritePokemon(from: pokemon)
        try? realm.write { realm.add(object) }
    }

    func removeFavorite(id: Int) {
        guard let object = realm.object(ofType: FavoritePokemon.self, forPrimaryKey: id) else { return }
        try? realm.write { realm.delete(object) }
    }
}
