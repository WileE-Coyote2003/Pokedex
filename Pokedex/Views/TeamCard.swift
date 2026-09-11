//
//  TeamCard.swift
//  Pokedex
//
import SwiftUI

struct TeamCard<Destination: View>: View {
    let name: String
    let members: [Pokemon]
    var capacity = PokemonTeam.capacity
    var pokeballAssetName = "teamPokeBall"
    var borderColor: Color = .red

    let destination: Destination

    private var pokemonCount: Int {
        min(members.count, capacity)
    }

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    Image(pokeballAssetName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("\(pokemonCount) / \(capacity) Pokémon")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                HStack(spacing: 8) {
                    ForEach(0..<capacity, id: \.self) { index in
                        TeamPokemonSlot(
                            pokemon: index < pokemonCount ? members[index] : nil
                        )
                    }
                }
            }
            .padding(16)
            .background(
                .background,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor.opacity(0.35), lineWidth: 1.5)
            }
            .shadow(
                color: .black.opacity(0.07),
                radius: 8,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TeamPokemonSlot: View {
    let pokemon: Pokemon?

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(uiColor: .secondarySystemBackground))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let pokemon {
                    PokemonArtworkView(pokemon: pokemon)
                        .padding(4)
                }
            }
            .overlay {
                if pokemon == nil {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.secondary.opacity(0.18),
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: [5, 4]
                            )
                        )
                }
            }
            .accessibilityLabel(
                pokemon.map { "\($0.name) team member" } ?? "Empty team slot"
            )
    }
}

#Preview {
    NavigationStack {
        TeamCard(
            name: "Kanto Champions",
            members: Array(samplePokemon.prefix(3)),
            destination: Text("Team details")
        )
        .padding()
    }
}
