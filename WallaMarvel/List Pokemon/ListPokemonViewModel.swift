//
//  ListPokemonViewModel.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation

@MainActor
final class ListPokemonViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = []
    @Published private(set) var isLoading: Bool = false

    private let getPokemonListUseCase: GetPokemonListUseCaseProtocol
    
    init(getPokemonListUseCase: GetPokemonListUseCaseProtocol = GetPokemonList()) {
        self.getPokemonListUseCase = getPokemonListUseCase
    }
    
    var title: String { "Pokédex" }
    
    func getPokemon() async {
        isLoading = true
        defer { isLoading = false }
        do {
            pokemon = try await getPokemonListUseCase.execute(limit: 20, offset: 0)
        } catch {
            // TODO: surface error in UI
        }
    }
}
