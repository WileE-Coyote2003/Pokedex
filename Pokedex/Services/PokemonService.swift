import Foundation

enum PokemonServiceError: Error {
    case notFound
    case invalidResponse
}

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

    func fetchPokemon(pokedexNumbers: [Int]) async throws -> [Pokemon] {
        guard pokedexNumbers.allSatisfy({ $0 > 0 }) else {
            throw URLError(.badURL)
        }

        return try await withThrowingTaskGroup(
            of: (Int, Pokemon).self
        ) { group in
            for (index, pokedexNumber) in pokedexNumbers.enumerated() {
                group.addTask { @MainActor in
                    let pokemon = try await fetchPokemon(
                        pokedexNumber: pokedexNumber
                    )
                    return (index, pokemon)
                }
            }

            var pokemonByIndex: [(index: Int, pokemon: Pokemon)] = []
            for try await result in group {
                pokemonByIndex.append(result)
            }

            return pokemonByIndex
                .sorted { $0.index < $1.index }
                .map(\.pokemon)
        }
    }

    func fetchSpeciesDetails(for pokemon: Pokemon) async throws -> PokemonSpeciesDetails {
        let speciesURL = try makeURL(
            pathComponents: ["pokemon-species", pokemon.speciesName]
        )
        let species = try await request(APIPokemonSpeciesResponse.self, from: speciesURL)
        let generation = try await request(
            APIGenerationResponse.self,
            from: species.generation.url
        )

        let region: String
        if let mainRegion = generation.mainRegion {
            let response = try await request(APIRegionResponse.self, from: mainRegion.url)
            region = response.englishName ?? formattedResourceName(mainRegion.name)
        } else {
            region = "Unknown"
        }

        return PokemonSpeciesDetails(
            name: species.englishName ?? pokemon.name,
            genus: species.englishGenus ?? "Pokémon",
            description: species.englishFlavorText ?? "No Pokédex description is available.",
            generation: generation.englishName
                ?? formattedResourceName(species.generation.name),
            region: region,
            habitat: species.habitat.map { formattedResourceName($0.name) },
            isBaby: species.isBaby,
            isLegendary: species.isLegendary,
            isMythical: species.isMythical
        )
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PokemonServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(type, from: data)
        case 404:
            throw PokemonServiceError.notFound
        default:
            throw PokemonServiceError.invalidResponse
        }
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

    private func formattedResourceName(_ name: String) -> String {
        name
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
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

private struct APIPokemonSpeciesResponse: Decodable {
    let names: [APILocalizedName]
    let genera: [APIGenus]
    let flavorTextEntries: [APIFlavorTextEntry]
    let habitat: APIResource?
    let generation: APIResource
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool

    var englishName: String? {
        names.first { $0.language.name == "en" }?.name
    }

    var englishGenus: String? {
        genera.first { $0.language.name == "en" }?.genus
    }

    var englishFlavorText: String? {
        flavorTextEntries
            .last { $0.language.name == "en" }?
            .flavorText
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case names
        case genera
        case flavorTextEntries = "flavor_text_entries"
        case habitat
        case generation
        case isBaby = "is_baby"
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
    }
}

private struct APIGenerationResponse: Decodable {
    let mainRegion: APIResource?
    let names: [APILocalizedName]

    var englishName: String? {
        names.first { $0.language.name == "en" }?.name
    }

    enum CodingKeys: String, CodingKey {
        case mainRegion = "main_region"
        case names
    }
}

private struct APIRegionResponse: Decodable {
    let names: [APILocalizedName]

    var englishName: String? {
        names.first { $0.language.name == "en" }?.name
    }
}

private struct APILocalizedName: Decodable {
    let name: String
    let language: APIResource
}

private struct APIGenus: Decodable {
    let genus: String
    let language: APIResource
}

private struct APIFlavorTextEntry: Decodable {
    let flavorText: String
    let language: APIResource

    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
    }
}

private struct APIResource: Decodable {
    let name: String
    let url: URL
}
