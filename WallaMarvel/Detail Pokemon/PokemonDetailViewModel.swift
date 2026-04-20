//
//  PokemonDetailViewModel.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var isLoading: Bool = true

    private let pokemonID: Int
    private let getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol

    init(pokemonID: Int, getPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol = GetPokemonDetail()) {
        self.pokemonID = pokemonID
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
    }

    func getDetail() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await getPokemonDetailUseCase.execute(id: pokemonID)
        } catch {
            // TODO: surface error in UI
        }
    }
}
