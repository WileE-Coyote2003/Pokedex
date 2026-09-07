//
//  CompareResultView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct CompareResultView: View {
    let pokemonA: Pokemon
    let pokemonB: Pokemon

    private var winner: Pokemon? {
        let totalA = statTotal(for: pokemonA)
        let totalB = statTotal(for: pokemonB)

        guard totalA != totalB else { return nil }
        return totalA > totalB ? pokemonA : pokemonB
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                headerRow
                statsCard
                resultCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Comparison Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            pokemonHeader(pokemonA)

            Text("VS")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.top, 38)

            pokemonHeader(pokemonB)
        }
    }

    private func pokemonHeader(_ pokemon: Pokemon) -> some View {
        VStack(spacing: 8) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 88, height: 88)
            .padding(6)
            .background(pokemonTypeColor(for: pokemon.primaryType).opacity(0.15), in: RoundedRectangle(cornerRadius: 16))

            Text(pokemon.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                ForEach(pokemon.types, id: \.self) { type in
                    CompareTypeLabel(type: type)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statsCard: some View {
        VStack(spacing: 14) {
            CompareStatRow(label: "HP", valueA: pokemonA.stats.hp, valueB: pokemonB.stats.hp, color: .red)
            CompareStatRow(label: "Attack", valueA: pokemonA.stats.attack, valueB: pokemonB.stats.attack, color: .orange)
            CompareStatRow(label: "Defense", valueA: pokemonA.stats.defense, valueB: pokemonB.stats.defense, color: .blue)
            CompareStatRow(label: "Speed", valueA: pokemonA.stats.speed, valueB: pokemonB.stats.speed, color: .green)

            Divider()

            CompareMetricRow(
                label: "Height",
                valueA: String(format: "%.1f m", pokemonA.height),
                valueB: String(format: "%.1f m", pokemonB.height)
            )
            CompareMetricRow(
                label: "Weight",
                valueA: String(format: "%.1f kg", pokemonA.weight),
                valueB: String(format: "%.1f kg", pokemonB.weight)
            )
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var resultCard: some View {
        HStack(spacing: 10) {
            Image(systemName: winner == nil ? "equal.circle.fill" : "trophy.fill")
                .foregroundStyle(.orange)
            Text(resultText)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .accessibilityElement(children: .combine)
    }

    private var resultText: String {
        guard let winner else { return "It’s a tie!" }
        return "Winner: \(winner.name)!"
    }

    private func statTotal(for pokemon: Pokemon) -> Int {
        pokemon.stats.hp + pokemon.stats.attack + pokemon.stats.defense + pokemon.stats.speed
    }
}

private struct CompareStatRow: View {
    let label: String
    let valueA: Int
    let valueB: Int
    let color: Color

    private func progress(_ value: Int) -> Double {
        min(Double(value) / 150.0, 1.0)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(valueA)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { proxy in
                ZStack(alignment: .trailing) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: proxy.size.width * progress(valueA))
                }
            }
            .frame(height: 10)

            Text(label)
                .font(.caption.weight(.semibold))
                .frame(width: 56)
                .multilineTextAlignment(.center)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: proxy.size.width * progress(valueB))
                }
            }
            .frame(height: 10)

            Text("\(valueB)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(valueA) versus \(valueB)")
    }
}

private struct CompareMetricRow: View {
    let label: String
    let valueA: String
    let valueB: String

    var body: some View {
        HStack {
            Text(valueA).frame(maxWidth: .infinity, alignment: .leading)
            Text(label).font(.subheadline.weight(.semibold)).frame(width: 70)
            Text(valueB).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(valueA) versus \(valueB)")
    }
}

private struct CompareTypeLabel: View {
    let type: String

    var body: some View {
        Text(type)
            .font(.caption2.weight(.bold))
            .foregroundStyle(pokemonTypeColor(for: type))
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(pokemonTypeColor(for: type).opacity(0.15), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        CompareResultView(pokemonA: samplePokemon[0], pokemonB: samplePokemon[1])
    }
}
