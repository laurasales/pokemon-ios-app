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
    @Published var searchText: String = ""
    @Published private(set) var searchResult: Pokemon? = nil
    @Published private(set) var searchNotFound: Bool = false

    private let getPokemonListUseCase: GetPokemonListUseCaseProtocol
    private let searchPokemonUseCase: SearchPokemonUseCaseProtocol
    private let pageSize: Int = 20
    private var currentOffset: Int = 0
    private var hasMore: Bool = true

    var isSearching: Bool { !searchText.isEmpty }

    init(
        getPokemonListUseCase: GetPokemonListUseCaseProtocol = GetPokemonList(),
        searchPokemonUseCase: SearchPokemonUseCaseProtocol = SearchPokemon()
    ) {
        self.getPokemonListUseCase = getPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
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

    func searchPokemon() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        searchResult = nil
        searchNotFound = false
        isLoading = true
        defer { isLoading = false }
        do {
            searchResult = try await searchPokemonUseCase.execute(query: query)
        } catch {
            searchNotFound = true
        }
    }

    func clearSearch() {
        searchText = ""
        searchResult = nil
        searchNotFound = false
    }
}
