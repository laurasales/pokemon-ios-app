//
//  MockGetPokemonTypesUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 23/4/26.
//

@testable import WallaMarvel

final class MockGetPokemonTypesUseCase: GetPokemonTypesUseCaseProtocol {
    private let result: Result<[String], Error>

    init(types: [String]) {
        result = .success(types)
    }
    init(error: Error) {
        result = .failure(error)
    }

    func execute() async throws -> [String] {
        try result.get()
    }
}
