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
            getPokemonListUseCase: GetPokemonList(repository: pokemonRepository),
            searchPokemonUseCase: SearchPokemon(repository: pokemonRepository),
            getPokemonByTypeUseCase: GetPokemonByType(repository: pokemonRepository),
            getPokemonTypesUseCase: GetPokemonTypes(repository: pokemonRepository),
            toggleFavoriteUseCase: ToggleFavorite(repository: favoritesRepository),
            getFavoritesUseCase: GetFavorites(repository: favoritesRepository)
        )
    }

    func makePokemonDetailViewModel(pokemonID: Int) -> PokemonDetailViewModel {
        PokemonDetailViewModel(
            pokemonID: pokemonID,
            getPokemonDetailUseCase: GetPokemonDetail(repository: pokemonRepository),
            toggleFavoriteUseCase: ToggleFavorite(repository: favoritesRepository)
        )
    }
}
