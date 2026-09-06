//
//  CompareResultView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct CompareResultView: View {

    let leftPokemon: Pokemon
    let rightPokemon: Pokemon

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                // MARK: - Pokémon Header

                HStack(spacing: 16) {

                    pokemonHeader(
                        pokemon: leftPokemon
                    )

                    VStack {
                        Text("VS")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.secondary)
                    }

                    pokemonHeader(
                        pokemon: rightPokemon
                    )
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // MARK: - Stats

                VStack(alignment: .leading, spacing: 20) {

                    Text("Base Stats")
                        .font(.title3.weight(.bold))

                    statRow(
                        name: "HP",
                        leftValue: leftPokemon.stats.hp,
                        rightValue: rightPokemon.stats.hp,
                        leftColor: typeColor(for: leftPokemon.primaryType),
                        rightColor: typeColor(for: rightPokemon.primaryType)
                    )

                    statRow(
                        name: "Attack",
                        leftValue: leftPokemon.stats.attack,
                        rightValue: rightPokemon.stats.attack,
                        leftColor: typeColor(for: leftPokemon.primaryType),
                        rightColor: typeColor(for: rightPokemon.primaryType)
                    )

                    statRow(
                        name: "Defense",
                        leftValue: leftPokemon.stats.defense,
                        rightValue: rightPokemon.stats.defense,
                        leftColor: typeColor(for: leftPokemon.primaryType),
                        rightColor: typeColor(for: rightPokemon.primaryType)
                    )

                    statRow(
                        name: "Speed",
                        leftValue: leftPokemon.stats.speed,
                        rightValue: rightPokemon.stats.speed,
                        leftColor: typeColor(for: leftPokemon.primaryType),
                        rightColor: typeColor(for: rightPokemon.primaryType)
                    )
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // MARK: - Information

                informationSection

            }
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .navigationTitle("Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }


    // MARK: - Pokémon Header

    private func pokemonHeader(
        pokemon: Pokemon
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
            .frame(height: 130)

            Text(pokemon.name)
                .font(.headline.weight(.bold))

            Text(pokemon.formattedNumber)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 5) {
                Text(typeIcon(for: pokemon.primaryType))

                Text(pokemon.primaryType)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(
                typeColor(for: pokemon.primaryType)
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                typeColor(for: pokemon.primaryType).opacity(0.12)
            )
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }


    // MARK: - Stat Row

    private func statRow(
        name: String,
        leftValue: Int,
        rightValue: Int,
        leftColor: Color,
        rightColor: Color
    ) -> some View {

        VStack(spacing: 7) {

            HStack {

                Text("\(leftValue)")
                    .font(.subheadline.weight(.bold))
                    .frame(width: 40, alignment: .leading)

                Spacer()

                Text(name)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(rightValue)")
                    .font(.subheadline.weight(.bold))
                    .frame(width: 40, alignment: .trailing)
            }

            HStack(spacing: 8) {

                statBar(
                    value: leftValue,
                    color: leftColor
                )

                statBar(
                    value: rightValue,
                    color: rightColor
                )
            }
        }
    }


    // MARK: - Stat Bar

    private func statBar(
        value: Int,
        color: Color
    ) -> some View {

        GeometryReader { geometry in

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(Color.gray.opacity(0.12))

                Capsule()
                    .fill(color)
                    .frame(
                        width: geometry.size.width *
                        CGFloat(min(value, 150)) / 150
                    )
            }
        }
        .frame(height: 9)
    }


    // MARK: - Information

    private var informationSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Information")
                .font(.title3.weight(.bold))

            informationRow(
                title: "Height",
                leftValue: String(format: "%.1f m", leftPokemon.height),
                rightValue: String(format: "%.1f m", rightPokemon.height)
            )

            informationRow(
                title: "Weight",
                leftValue: String(format: "%.1f kg", leftPokemon.weight),
                rightValue: String(format: "%.1f kg", rightPokemon.weight)
            )

            informationRow(
                title: "Type",
                leftValue: leftPokemon.types.joined(separator: " / "),
                rightValue: rightPokemon.types.joined(separator: " / ")
            )

            informationRow(
                title: "Abilities",
                leftValue: leftPokemon.abilities.joined(separator: ", "),
                rightValue: rightPokemon.abilities.joined(separator: ", ")
            )
        }
        .padding(.horizontal)
    }


    // MARK: - Information Row

    private func informationRow(
        title: String,
        leftValue: String,
        rightValue: String
    ) -> some View {

        HStack(alignment: .top, spacing: 10) {

            VStack(alignment: .leading, spacing: 4) {

                Text(leftValue)
                    .font(.subheadline.weight(.semibold))

                Text(leftPokemon.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(width: 65)

            VStack(alignment: .trailing, spacing: 4) {

                Text(rightValue)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.trailing)

                Text(rightPokemon.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}


#Preview {

    NavigationStack {

        CompareResultView(
            leftPokemon: samplePokemon[0],
            rightPokemon: samplePokemon[3]
        )
    }
}