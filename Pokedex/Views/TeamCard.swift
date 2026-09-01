//
//  TeamCard.swift
//  Pokedex
//
import SwiftUI

struct TeamCard<Destination: View>: View {
    let name: String
    let pokemonCount: Int
    var capacity = 6
    var pokeballAssetName = "teamPokeBall"
    var borderColor: Color = .red

    let destination: Destination

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
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
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

//#Preview {
//    TeamCard(name: "Kanto Champions", pokemonCount: 0)
//        .padding()
//}
