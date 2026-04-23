//
//  MockGetPokemonListUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 23/4/26.
//

@testable import WallaMarvel

final class MockGetPokemonListUseCase: GetPokemonListUseCaseProtocol {
    private let result: Result<[Pokemon], Error>

    init(pokemon: [Pokemon]) { self.result = .success(pokemon) }
    init(error: Error) { self.result = .failure(error) }

    func execute(limit: Int, offset: Int) async throws -> [Pokemon] {
        try result.get()
    }
}
