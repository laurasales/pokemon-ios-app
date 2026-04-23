//
//  FavoritesRepositoryProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 23/4/26.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func getFavorites() -> [Pokemon]
    func isFavorite(id: Int) -> Bool
    func addFavorite(_ pokemon: Pokemon)
    func removeFavorite(id: Int)
}
