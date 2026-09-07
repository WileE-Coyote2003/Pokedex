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
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Compare Pokémon")
                        .font(.title2.weight(.bold))

                    Text("Choose two Pokémon to compare their stats.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)

                // MARK: - Pokémon Selection
                HStack(spacing: 12) {

                    pokemonSelector(
                        pokemon: leftPokemon,
                        action: {
                            showingLeftPicker = true
                        }
                    )

                    Text("VS")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondary)

                    pokemonSelector(
                        pokemon: rightPokemon,
                        action: {
                            showingRightPicker = true
                        }
                    )
                }
                .padding(.horizontal)

                // MARK: - Pokémon Preview
                HStack(spacing: 20) {

                    pokemonPreview(
                        pokemon: leftPokemon,
                        accentColor: typeColor(for: leftPokemon.primaryType)
                    )

                    Text("VS")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondary)

                    pokemonPreview(
                        pokemon: rightPokemon,
                        accentColor: typeColor(for: rightPokemon.primaryType)
                    )
                }
                .padding(.horizontal)

                // MARK: - Compare Button
                NavigationLink {
                    CompareResultView(
                        leftPokemon: leftPokemon,
                        rightPokemon: rightPokemon
                    )
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                        Text("Compare")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(
                        canCompare
                        ? Color.blue
                        : Color.gray.opacity(0.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canCompare)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Left Pokémon Sheet
        .sheet(isPresented: $showingLeftPicker) {
            PokemonPickerView(
                title: "Select Left Pokémon",
                selectedPokemon: $leftPokemon,
                otherPokemon: rightPokemon
            )
        }

        // MARK: - Right Pokémon Sheet
        .sheet(isPresented: $showingRightPicker) {
            PokemonPickerView(
                title: "Select Right Pokémon",
                selectedPokemon: $rightPokemon,
                otherPokemon: leftPokemon
            )
        }
    }

    // MARK: - Selector

    private func pokemonSelector(
        pokemon: Pokemon,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            HStack {
                Text(pokemon.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                typeColor(for: pokemon.primaryType).opacity(0.10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        typeColor(for: pokemon.primaryType).opacity(0.25),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pokémon Preview

    private func pokemonPreview(
        pokemon: Pokemon,
        accentColor: Color
    ) -> some View {

        VStack(spacing: 8) {

            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()

                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                case .empty:
                    ProgressView()

                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 135)

            Text(pokemon.name)
                .font(.headline.weight(.bold))

            Text(pokemon.formattedNumber)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            typePill(for: pokemon.primaryType)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            accentColor.opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Type Pill

    private func typePill(for type: String) -> some View {
        HStack(spacing: 5) {
            Text(typeIcon(for: type))
            Text(type)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(typeColor(for: type))
        .background(typeColor(for: type).opacity(0.12))
        .clipShape(Capsule())
    }
}


// MARK: - Pokémon Picker

struct PokemonPickerView: View {

    let title: String
    @Binding var selectedPokemon: Pokemon
    let otherPokemon: Pokemon

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private var filteredPokemon: [Pokemon] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return samplePokemon
        }

        let query = searchText.lowercased()

        return samplePokemon.filter {
            $0.name.lowercased().contains(query) ||
            $0.formattedNumber.contains(query)
        }
    }

    var body: some View {

        NavigationStack {

            List {

                ForEach(filteredPokemon) { pokemon in

                    Button {
                        selectedPokemon = pokemon
                        dismiss()
                    } label: {

                        HStack(spacing: 14) {

                            AsyncImage(url: pokemon.imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()

                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)

                                case .empty:
                                    ProgressView()

                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 55, height: 55)

                            VStack(alignment: .leading, spacing: 3) {

                                Text(pokemon.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(pokemon.formattedNumber)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(pokemon.types.joined(separator: " / "))
                                    .font(.caption)
                                    .foregroundStyle(
                                        typeColor(for: pokemon.primaryType)
                                    )
                            }

                            Spacer()

                            if pokemon.id == selectedPokemon.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(
                                        typeColor(for: pokemon.primaryType)
                                    )
                            }

                            if pokemon.id == otherPokemon.id {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(pokemon.id == otherPokemon.id)
                }
            }
            .searchable(
                text: $searchText,
                prompt: "Search Pokémon"
            )
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
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