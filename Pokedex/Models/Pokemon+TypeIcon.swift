extension Pokemon {
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
