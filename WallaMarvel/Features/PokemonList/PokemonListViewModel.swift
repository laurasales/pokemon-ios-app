//
//  PokemonListViewModel.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 21/4/26.
//

import Foundation
import os

@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = []
    @Published private(set) var isListLoading: Bool = false
    @Published private(set) var isPaginationLoading: Bool = false
    @Published private(set) var isSearchLoading: Bool = false
    @Published private(set) var isTypeFilterLoading: Bool = false
    @Published var searchText: String = ""
    @Published private(set) var hasSearched: Bool = false
    @Published private(set) var searchResult: Pokemon? = nil
    @Published private(set) var searchNotFound: Bool = false
    @Published private(set) var selectedType: String? = nil
    @Published private(set) var filteredPokemon: [Pokemon] = []
    @Published private(set) var pokemonTypes: [String] = []
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var favorites: [Pokemon] = []
    @Published private(set) var showingFavoritesOnly: Bool = false

    private let getPokemonListUseCase: GetPokemonListUseCaseProtocol
    private let searchPokemonUseCase: SearchPokemonUseCaseProtocol
    private let getPokemonByTypeUseCase: GetPokemonByTypeUseCaseProtocol
    private let getPokemonTypesUseCase: GetPokemonTypesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    private let getFavoritesUseCase: GetFavoritesUseCaseProtocol
    private let pageSize: Int = 20
    private var currentOffset: Int = 0
    private var hasMore: Bool = true

    var isSearching: Bool { !searchText.isEmpty }

    var displayedPokemon: [Pokemon] {
        if showingFavoritesOnly { return favorites }
        if selectedType != nil { return filteredPokemon }
        return pokemon
    }
    
    init(
        getPokemonListUseCase: GetPokemonListUseCaseProtocol,
        searchPokemonUseCase: SearchPokemonUseCaseProtocol,
        getPokemonByTypeUseCase: GetPokemonByTypeUseCaseProtocol,
        getPokemonTypesUseCase: GetPokemonTypesUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        getFavoritesUseCase: GetFavoritesUseCaseProtocol
    ) {
        self.getPokemonListUseCase = getPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
        self.getPokemonByTypeUseCase = getPokemonByTypeUseCase
        self.getPokemonTypesUseCase = getPokemonTypesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getFavoritesUseCase = getFavoritesUseCase
    }
    
    var title: String { "Pokédex" }
    
    func dismissError() {
        errorMessage = nil
    }
    
    func loadFavorites() {
        favorites = getFavoritesUseCase.execute()
    }
    
    func toggleShowFavoritesOnly() {
        showingFavoritesOnly.toggle()
        if showingFavoritesOnly {
            selectedType = nil
            filteredPokemon = []
            loadFavorites()
        }
    }
    
    func isFavorite(_ pokemon: Pokemon) -> Bool {
        toggleFavoriteUseCase.isFavorite(id: pokemon.id)
    }
    
    func toggleFavorite(_ pokemon: Pokemon) {
        toggleFavoriteUseCase.execute(pokemon: pokemon)
        loadFavorites()
    }
    
    func loadTypes() async {
        do {
            pokemonTypes = try await getPokemonTypesUseCase.execute()
            Logger.network.debug("Loaded \(self.pokemonTypes.count) Pokémon types")
        } catch {
            Logger.network.error("Failed to load Pokémon types: \(error)")
        }
    }
    
    func getPokemon() async {
        guard !isListLoading else { return }
        isListLoading = true
        defer { isListLoading = false }
        do {
            let result = try await getPokemonListUseCase.execute(limit: pageSize, offset: 0)
            pokemon = result
            currentOffset = result.count
            hasMore = result.count == pageSize
            Logger.network.debug("Loaded \(result.count) Pokémon")
        } catch {
            Logger.network.error("Failed to load Pokémon list: \(error)")
            errorMessage = "Failed to load Pokémon. Please try again."
        }
    }

    func loadMoreIfNeeded(currentPokemon: Pokemon) async {
        guard selectedType == nil, hasMore, !isListLoading, !isPaginationLoading else { return }
        guard let index = pokemon.firstIndex(where: { $0.id == currentPokemon.id }),
              index >= pokemon.count - 5 else { return }
        isPaginationLoading = true
        defer { isPaginationLoading = false }
        do {
            let result = try await getPokemonListUseCase.execute(limit: pageSize, offset: currentOffset)
            pokemon.append(contentsOf: result)
            currentOffset += result.count
            hasMore = result.count == pageSize
            Logger.network.debug("Loaded \(result.count) more Pokémon, total: \(self.pokemon.count)")
        } catch {
            Logger.network.error("Failed to load more Pokémon at offset \(self.currentOffset): \(error)")
            errorMessage = "Failed to load more Pokémon. Please try again."
        }
    }

    func searchPokemon() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        searchResult = nil
        searchNotFound = false
        hasSearched = true
        isSearchLoading = true
        defer { isSearchLoading = false }
        Logger.ui.debug("Searching for Pokémon with query: \(query, privacy: .private)")
        do {
            searchResult = try await searchPokemonUseCase.execute(query: query)
            Logger.network.debug("Search succeeded for query: \(query, privacy: .private)")
        } catch {
            Logger.network.error("Search failed for query \(query, privacy: .private): \(error)")
            searchNotFound = true
        }
    }
    
    func resetSearchResults() {
        searchResult = nil
        searchNotFound = false
        hasSearched = false
    }
    
    func clearSearch() {
        searchText = ""
        resetSearchResults()
    }
    
    func selectType(_ type: String) async {
        if selectedType == type {
            Logger.ui.debug("Deselected Pokémon type: \(type)")
            selectedType = nil
            filteredPokemon = []
            return
        }
        showingFavoritesOnly = false
        Logger.ui.debug("Selected Pokémon type: \(type)")
        selectedType = type
        await loadFilteredPokemon(forType: type)
    }

    func refreshCurrentTypeFilter() async {
        guard let type = selectedType else { return }
        await loadFilteredPokemon(forType: type)
    }

    private func loadFilteredPokemon(forType typeName: String) async {
        filteredPokemon = []
        isTypeFilterLoading = true
        defer { isTypeFilterLoading = false }
        do {
            filteredPokemon = try await getPokemonByTypeUseCase.execute(typeName: typeName)
            Logger.network.debug("Loaded \(self.filteredPokemon.count) Pokémon for type: \(typeName)")
        } catch {
            Logger.network.error("Failed to load Pokémon for type \(typeName): \(error)")
            selectedType = nil
            errorMessage = "Failed to load \(typeName.capitalized) type Pokémon. Please try again."
        }
    }
}
