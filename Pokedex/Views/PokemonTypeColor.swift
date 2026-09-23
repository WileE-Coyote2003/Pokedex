import SwiftUI

func pokemonTypeColor(for type: String) -> Color {
    switch type.lowercased() {
    case "fire": .orange
    case "water": .blue
    case "grass": .green
    case "electric": .yellow
    case "psychic", "fairy": .pink
    case "poison": .purple
    case "flying": .cyan
    case "bug": .mint
    case "fighting": .red
    case "ground": .brown
    case "rock", "steel": .gray
    case "ghost", "dragon": .indigo
    case "ice": .teal
    case "dark": .black
    default: .secondary
    }
}
