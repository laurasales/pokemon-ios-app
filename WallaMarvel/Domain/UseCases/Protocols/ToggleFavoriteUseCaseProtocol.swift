//
//  ToggleFavoriteUseCaseProtocol.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import Foundation

protocol ToggleFavoriteUseCaseProtocol {
    func execute(pokemon: Pokemon)
    func isFavorite(id: Int) -> Bool
}
