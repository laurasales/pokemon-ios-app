//
//  PokemonDetailViewModel.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation
import os

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isFavorite: Bool = false

    private let pokemonID: Int
    private let getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol

    init(
        pokemonID: Int,
        getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    ) {
        self.pokemonID = pokemonID
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.isFavorite = toggleFavoriteUseCase.isFavorite(id: pokemonID)
    }

    func dismissError() {
        errorMessage = nil
    }

    func toggleFavorite() {
        guard let detail = detail else { return }
        let pokemon = Pokemon(id: detail.id, name: detail.name, imageURL: detail.imageURL)
        toggleFavoriteUseCase.execute(pokemon: pokemon)
        isFavorite = toggleFavoriteUseCase.isFavorite(id: pokemonID)
    }

    func getDetail() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await getPokemonDetailUseCase.execute(id: pokemonID)
            Logger.network.debug("Loaded detail for Pokémon ID: \(self.pokemonID)")
        } catch {
            Logger.network.error("Failed to load detail for Pokémon ID \(self.pokemonID): \(error)")
            errorMessage = "Failed to load Pokémon details. Please try again."
        }
    }
}
