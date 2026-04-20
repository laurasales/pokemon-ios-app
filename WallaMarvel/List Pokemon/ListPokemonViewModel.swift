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
    private let pageSize: Int = 20
    private var currentOffset: Int = 0
    private var hasMore: Bool = true

    init(getPokemonListUseCase: GetPokemonListUseCaseProtocol = GetPokemonList()) {
        self.getPokemonListUseCase = getPokemonListUseCase
    }

    var title: String { "Pokédex" }

    func getPokemon() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await getPokemonListUseCase.execute(limit: pageSize, offset: 0)
            pokemon = result
            currentOffset = result.count
            hasMore = result.count == pageSize
        } catch {
            // TODO: surface error in UI
        }
    }

    func loadMoreIfNeeded(currentPokemon: Pokemon) async {
        guard hasMore, !isLoading else { return }
        guard let index = pokemon.firstIndex(where: { $0.id == currentPokemon.id }),
              index >= pokemon.count - 5 else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await getPokemonListUseCase.execute(limit: pageSize, offset: currentOffset)
            pokemon.append(contentsOf: result)
            currentOffset += result.count
            hasMore = result.count == pageSize
        } catch {
            // TODO: surface error in UI
        }
    }
}
