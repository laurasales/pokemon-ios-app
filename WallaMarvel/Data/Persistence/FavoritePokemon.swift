//
//  FavoritePokemon.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation
import RealmSwift

final class FavoritePokemon: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var imageURLString: String

    convenience init(from pokemon: Pokemon) {
        self.init()
        id = pokemon.id
        name = pokemon.name
        imageURLString = pokemon.imageURL.absoluteString
    }

    func toDomain() -> Pokemon? {
        guard let url = URL(string: imageURLString) else { return nil }
        return Pokemon(id: id, name: name, imageURL: url)
    }
}
