//
//  ListPokemonPresenter.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

protocol ListPokemonPresenterProtocol: AnyObject {
    var ui: ListPokemonUI? { get set }
    func screenTitle() -> String
    func getPokemon()
}

protocol ListPokemonUI: AnyObject {
    func update(pokemon: [Pokemon])
}

final class ListPokemonPresenter: ListPokemonPresenterProtocol {
    var ui: ListPokemonUI?
    private let getPokemonListUseCase: GetPokemonListUseCaseProtocol

    init(getPokemonListUseCase: GetPokemonListUseCaseProtocol = GetPokemonList()) {
        self.getPokemonListUseCase = getPokemonListUseCase
    }

    func screenTitle() -> String {
        "Pokédex"
    }

    func getPokemon() {
        Task { @MainActor in
            do {
                let pokemon = try await getPokemonListUseCase.execute(limit: 20, offset: 0)
                ui?.update(pokemon: pokemon)
            } catch {
                // TODO: surface error in UI
            }
        }
    }
}
