//
//  DependencyContainer.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import os
import RealmSwift
import SwiftUI

@MainActor
final class DependencyContainer: ObservableObject {
    private let pokemonRepository: PokemonRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    init() {
        let networkService = OpenAPIPokemonNetworkService()
        pokemonRepository = PokemonRepository(networkService: networkService)
        favoritesRepository = FavoritesRepository(realm: Self.makeRealm())
    }

    private static func makeRealm() -> Realm {
        if let realm = try? Realm() {
            Logger.persistence.debug("Realm initialized at: \(realm.configuration.fileURL?.path ?? "unknown")")
            return realm
        }
        Logger.persistence.warning("Default Realm initialization failed, falling back to in-memory store")
        let config = Realm.Configuration(inMemoryIdentifier: "favorites-fallback")
        guard let realm = try? Realm(configuration: config) else {
            preconditionFailure("Failed to initialize Realm with in-memory fallback")
        }
        return realm
    }

    func makePokemonListViewModel() -> PokemonListViewModel {
        PokemonListViewModel(
            getPokemonListUseCase: GetPokemonListUseCase(repository: pokemonRepository),
            searchPokemonUseCase: SearchPokemonUseCase(repository: pokemonRepository),
            getPokemonByTypeUseCase: GetPokemonByTypeUseCase(repository: pokemonRepository),
            getPokemonTypesUseCase: GetPokemonTypesUseCase(repository: pokemonRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository),
            getFavoritesUseCase: GetFavoritesUseCase(repository: favoritesRepository)
        )
    }

    func makePokemonDetailViewModel(pokemonID: Int) -> PokemonDetailViewModel {
        PokemonDetailViewModel(
            pokemonID: pokemonID,
            getPokemonDetailUseCase: GetPokemonDetailUseCase(repository: pokemonRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoritesRepository)
        )
    }
}
