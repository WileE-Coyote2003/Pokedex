import Foundation

struct PokemonPage {
    let pokemon: [Pokemon]
    let totalCount: Int
    let limit: Int
    let offset: Int

    var nextOffset: Int? {
        let nextOffset = offset + limit
        return nextOffset < totalCount ? nextOffset : nil
    }

    var previousOffset: Int? {
        guard offset > 0 else { return nil }
        return max(0, offset - limit)
    }
}

struct PokemonService {
    private let session: URLSession
    private let maximumConcurrentDetailRequests = 8

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemon(name: String) async throws -> Pokemon {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !name.isEmpty else {
            throw URLError(.badURL)
        }

        return try await fetchPokemon(identifier: name)
    }

    func fetchPokemon(pokedexNumber: Int) async throws -> Pokemon {
        guard pokedexNumber > 0 else {
            throw URLError(.badURL)
        }

        return try await fetchPokemon(identifier: String(pokedexNumber))
    }

    func fetchPokemon(type: String) async throws -> [Pokemon] {
        let type = type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !type.isEmpty else {
            throw URLError(.badURL)
        }

        let url = try makeURL(pathComponents: ["type", type])
        let response = try await request(APITypeResponse.self, from: url)
        let resources = response.pokemon.map(\.pokemon)

        return try await fetchPokemonDetails(from: resources)
    }

    func fetchPokemon(limit: Int = 20, offset: Int = 0) async throws -> PokemonPage {
        guard limit > 0, offset >= 0 else {
            throw URLError(.badURL)
        }

        let url = try makeURL(
            pathComponents: ["pokemon"],
            queryItems: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]
        )
        let response = try await request(APIListResponse.self, from: url)
        let pokemon = try await fetchPokemonDetails(from: response.results)

        return PokemonPage(
            pokemon: pokemon,
            totalCount: response.count,
            limit: limit,
            offset: offset
        )
    }

    private func fetchPokemon(identifier: String) async throws -> Pokemon {
        let url = try makeURL(pathComponents: ["pokemon", identifier])
        return try await request(Pokemon.self, from: url)
    }

    private func fetchPokemonDetails(
        from resources: [APIResource]
    ) async throws -> [Pokemon] {
        var pokemonByIndex: [(index: Int, pokemon: Pokemon)] = []

        for batchStart in stride(
            from: 0,
            to: resources.count,
            by: maximumConcurrentDetailRequests
        ) {
            let batchEnd = min(
                batchStart + maximumConcurrentDetailRequests,
                resources.count
            )
            let batch = resources[batchStart..<batchEnd]

            let batchPokemon = try await withThrowingTaskGroup(
                of: (Int, Pokemon).self
            ) { group in
                for (index, resource) in zip(batch.indices, batch) {
                    group.addTask { @MainActor in
                        let pokemon = try await request(Pokemon.self, from: resource.url)
                        return (index, pokemon)
                    }
                }

                var results: [(Int, Pokemon)] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }

            pokemonByIndex.append(contentsOf: batchPokemon)
        }

        return pokemonByIndex
            .sorted { $0.index < $1.index }
            .map(\.pokemon)
    }

    private func request<Value: Decodable>(
        _ type: Value.Type,
        from url: URL
    ) async throws -> Value {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(type, from: data)
    }

    private func makeURL(
        pathComponents: [String],
        queryItems: [URLQueryItem] = []
    ) throws -> URL {
        guard let baseURL = URL(string: "https://pokeapi.co/api/v2") else {
            throw URLError(.badURL)
        }

        let endpoint = pathComponents.reduce(baseURL) { url, component in
            url.appendingPathComponent(component)
        }
        guard var components = URLComponents(
            url: endpoint,
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return url
    }
}

private struct APIListResponse: Decodable {
    let count: Int
    let results: [APIResource]
}

private struct APITypeResponse: Decodable {
    let pokemon: [APITypePokemon]
}

private struct APITypePokemon: Decodable {
    let pokemon: APIResource
}

private struct APIResource: Decodable {
    let name: String
    let url: URL
}
