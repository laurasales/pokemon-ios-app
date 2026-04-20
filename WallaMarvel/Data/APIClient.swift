//
//  APIClient.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import Foundation

protocol APIClientProtocol {
    func getPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponseDTO
}

final class APIClient: APIClientProtocol {
    private enum Constant {
        static let baseURL = "https://pokeapi.co/api/v2"
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponseDTO {
        var components = URLComponents(string: "\(Constant.baseURL)/pokemon")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(PokemonListResponseDTO.self, from: data)
    }
}
