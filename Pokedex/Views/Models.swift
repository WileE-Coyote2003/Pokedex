import Foundation

struct Pokemon: Identifiable, Hashable {
    let id: Int
    let name: String
    let types: [String]

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
    Pokemon(id: 25, name: "Pikachu", types: ["Electric"]),
    Pokemon(id: 6, name: "Charizard", types: ["Fire", "Flying"]),
    Pokemon(id: 1, name: "Bulbasaur", types: ["Grass", "Poison"]),
    Pokemon(id: 7, name: "Squirtle", types: ["Water"]),
    Pokemon(id: 26, name: "Raichu", types: ["Electric"]),
    Pokemon(id: 4, name: "Charmander", types: ["Fire"]),
    Pokemon(id: 8, name: "Wartortle", types: ["Water"]),
    Pokemon(id: 2, name: "Ivysaur", types: ["Grass", "Poison"])
]