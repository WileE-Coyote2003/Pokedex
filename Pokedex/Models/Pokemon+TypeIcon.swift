extension Pokemon {
    static let allTypes = [
        "Normal",
        "Fire",
        "Water",
        "Electric",
        "Grass",
        "Ice",
        "Fighting",
        "Poison",
        "Ground",
        "Flying",
        "Psychic",
        "Bug",
        "Rock",
        "Ghost",
        "Dragon",
        "Dark",
        "Steel",
        "Fairy"
    ]

    var typeIcon: String {
        switch primaryType.lowercased() {
        case "fire": "🔥"
        case "water": "💧"
        case "grass": "🌿"
        case "electric": "⚡"
        case "psychic": "🔮"
        case "poison": "☠️"
        case "flying": "🪽"
        case "bug": "🐛"
        case "normal": "⚪️"
        case "fighting": "🥊"
        case "ground": "🟤"
        case "rock": "🪨"
        case "ghost": "👻"
        case "ice": "❄️"
        case "dragon": "🐉"
        case "dark": "🌑"
        case "steel": "⚙️"
        case "fairy": "✨"
        default: "•"
        }
    }
}
