import Foundation

struct PokemonService {

    func fetchPokemon(name: String) async throws -> Pokemon {
        let pokemonName = name.lowercased()
        guard let url = URL(
            string: "https://pokeapi.co/api/v2/pokemon/\(pokemonName)"
        ) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let pokemon = try JSONDecoder().decode(
            Pokemon.self,
            from: data
        )

        return pokemon
    }
}
