//
//  SceneDelegate.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit
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

    func makePokemonListViewModel() -> ListPokemonViewModel {
        ListPokemonViewModel(
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

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let container = DependencyContainer()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let rootView = PokemonListView(viewModel: container.makePokemonListViewModel())
            .environmentObject(container)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}
