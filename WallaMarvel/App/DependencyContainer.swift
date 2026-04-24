//
//  DependencyContainer.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 24/4/26.
//

import SwiftUI
import RealmSwift

@MainActor
final class DependencyContainer: ObservableObject {
    private let pokemonRepository: PokemonRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    init() {
        let networkService = OpenAPIPokemonNetworkService()
        pokemonRepository = PokemonRepository(networkService: networkService)

        if let realm = try? Realm() {
            favoritesRepository = FavoritesRepository(realm: realm)
        } else {
            let config = Realm.Configuration(inMemoryIdentifier: "favorites-fallback")
            favoritesRepository = FavoritesRepository(realm: try! Realm(configuration: config))
        }
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
