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

    private let pokemonID: Int
    private let getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol

    init(pokemonID: Int, getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol = GetPokemonDetail()) {
        self.pokemonID = pokemonID
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
    }

    func dismissError() {
        errorMessage = nil
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
