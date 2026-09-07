//
//  CompareView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct CompareView: View {

    @State private var leftPokemon: Pokemon = samplePokemon[0]
    @State private var rightPokemon: Pokemon = samplePokemon[3]

    @State private var showingLeftPicker = false
    @State private var showingRightPicker = false

    private var canCompare: Bool {
        leftPokemon.id != rightPokemon.id
    }

    var body: some View {
        ComparePickerView(pokemon: samplePokemon)
    }
}

#Preview {
    NavigationStack {
        CompareView()
    }
}


// MARK: - Colors

func typeColor(for type: String) -> Color {

    switch type.lowercased() {

    case "electric":
        return Color.yellow

    case "water":
        return Color.blue

    case "fire":
        return Color.red

    case "grass":
        return Color.green

    case "poison":
        return Color.purple

    case "flying":
        return Color.indigo

    case "psychic":
        return Color.pink

    case "ice":
        return Color.cyan

    case "rock":
        return Color.brown

    case "ground":
        return Color.orange

    case "bug":
        return Color.mint

    case "ghost":
        return Color.purple

    case "dragon":
        return Color.indigo

    case "dark":
        return Color.black

    case "steel":
        return Color.gray

    case "fairy":
        return Color.pink

    case "fighting":
        return Color.red

    default:
        return Color.gray
    }
}


func typeIcon(for type: String) -> String {

    switch type.lowercased() {

    case "electric":
        return "⚡"

    case "water":
        return "💧"

    case "fire":
        return "🔥"

    case "grass":
        return "🌿"

    case "poison":
        return "☠️"

    case "flying":
        return "🪽"

    case "psychic":
        return "🔮"

    case "ice":
        return "❄️"

    case "rock":
        return "🪨"

    case "ground":
        return "🌎"

    case "bug":
        return "🐛"

    case "ghost":
        return "👻"

    case "dragon":
        return "🐉"

    case "dark":
        return "🌑"

    case "steel":
        return "⚙️"

    case "fairy":
        return "✨"

    case "fighting":
        return "🥊"

    default:
        return "●"
    }
}


#Preview {
    NavigationStack {
        CompareView()
    }
}