//
//  MockGetPokemonDetailUseCase.swift
//  WallaMarvelTests
//
//  Created by Laura Sales Martínez on 23/4/26.
//

@testable import WallaMarvel

final class MockGetPokemonDetailUseCase: GetPokemonDetailUseCaseProtocol {
    private let result: Result<PokemonDetail, Error>

    init(detail: PokemonDetail) {
        result = .success(detail)
    }
    init(error: Error) {
        result = .failure(error)
    }

    func execute(id: Int) async throws -> PokemonDetail {
        try result.get()
    }
}
