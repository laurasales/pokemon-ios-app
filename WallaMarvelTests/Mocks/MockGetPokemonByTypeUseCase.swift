//
//  MockGetPokemonByTypeUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 23/4/26.
//

@testable import WallaMarvel

final class MockGetPokemonByTypeUseCase: GetPokemonByTypeUseCaseProtocol {
    private let result: Result<[Pokemon], Error>

    init(pokemon: [Pokemon]) {
        result = .success(pokemon)
    }
    init(error: Error) {
        result = .failure(error)
    }

    func execute(typeName: String) async throws -> [Pokemon] {
        try result.get()
    }
}
