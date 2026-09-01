import Foundation

struct PokemonStats: Hashable {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
}

struct Pokemon: Identifiable, Hashable {
    let id: Int
    let name: String
    let types: [String]
    let height: Double
    let weight: Double
    let stats: PokemonStats
    let abilities: [String]

    var primaryType: String {
        types.first ?? "Normal"
    }

    var formattedNumber: String {
        String(format: "#%03d", id)
    }

    var typeIcon: String {
        switch primaryType.lowercased() {
        case "fire":
            return "🔥"
        case "water":
            return "💧"
        case "grass":
            return "🌿"
        case "electric":
            return "⚡"
        case "psychic":
            return "🔮"
        case "poison":
            return "☠️"
        case "flying":
            return "🪽"
        case "bug":
            return "🐛"
        case "normal":
            return "⚪️"
        case "fighting":
            return "🥊"
        case "ground":
            return "🟤"
        case "rock":
            return "🪨"
        case "ghost":
            return "👻"
        case "ice":
            return "❄️"
        case "dragon":
            return "🐉"
        case "dark":
            return "🌑"
        case "steel":
            return "⚙️"
        case "fairy":
            return "✨"
        default:
            return "•"
        }
    }

    var imageURL: URL? {
        URL(
            string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        )
    }
}

let samplePokemon: [Pokemon] = [
    Pokemon(id: 25, name: "Pikachu", types: ["Electric"], height: 0.4, weight: 6.0,
            stats: PokemonStats(hp: 35, attack: 55, defense: 40, speed: 90),
            abilities: ["Static", "Lightning Rod"]),
    Pokemon(id: 6, name: "Charizard", types: ["Fire", "Flying"], height: 1.7, weight: 90.5,
            stats: PokemonStats(hp: 78, attack: 84, defense: 78, speed: 100),
            abilities: ["Blaze", "Solar Power"]),
    Pokemon(id: 1, name: "Bulbasaur", types: ["Grass", "Poison"], height: 0.7, weight: 6.9,
            stats: PokemonStats(hp: 45, attack: 49, defense: 49, speed: 45),
            abilities: ["Overgrow", "Chlorophyll"]),
    Pokemon(id: 7, name: "Squirtle", types: ["Water"], height: 0.5, weight: 9.0,
            stats: PokemonStats(hp: 44, attack: 48, defense: 65, speed: 43),
            abilities: ["Torrent", "Rain Dish"]),
    Pokemon(id: 26, name: "Raichu", types: ["Electric"], height: 0.8, weight: 30.0,
            stats: PokemonStats(hp: 60, attack: 90, defense: 55, speed: 110),
            abilities: ["Static", "Lightning Rod"]),
    Pokemon(id: 4, name: "Charmander", types: ["Fire"], height: 0.6, weight: 8.5,
            stats: PokemonStats(hp: 39, attack: 52, defense: 43, speed: 65),
            abilities: ["Blaze", "Solar Power"]),
    Pokemon(id: 8, name: "Wartortle", types: ["Water"], height: 1.0, weight: 22.5,
            stats: PokemonStats(hp: 59, attack: 63, defense: 80, speed: 58),
            abilities: ["Torrent", "Rain Dish"]),
    Pokemon(id: 2, name: "Ivysaur", types: ["Grass", "Poison"], height: 1.0, weight: 13.0,
            stats: PokemonStats(hp: 60, attack: 62, defense: 63, speed: 60),
            abilities: ["Overgrow", "Chlorophyll"])
]
