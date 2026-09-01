//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @Binding var isFavorite: Bool
    @State private var addedToTeam = false

    private var themeColor: Color { pokemon.primaryType.color }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroSection
                dimensionsSection
                statsSection
                abilitiesSection
                teamButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .background(
            LinearGradient(
                colors: [themeColor.opacity(0.16), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(pokemon.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [themeColor.opacity(0.55), themeColor.opacity(0.05)],
                            center: .center,
                            startRadius: 4,
                            endRadius: 110
                        )
                    )
                    .frame(width: 190, height: 190)

                AsyncImage(url: pokemon.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "pawprint.fill")
                            .resizable().scaledToFit().padding(40)
                            .foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 170, height: 170)
                .shadow(color: themeColor.opacity(0.35), radius: 12, y: 6)
            }

            Text(pokemon.numberText)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(themeColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(themeColor.opacity(0.15), in: Capsule())

            Text(pokemon.name.uppercased())
                .font(.title.weight(.heavy))

            HStack(spacing: 8) {
                ForEach(pokemon.types, id: \.self) { type in
                    PokemonTypeLabel(type: type, filled: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [themeColor.opacity(0.28), themeColor.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(themeColor.opacity(0.35), lineWidth: 1.5)
        }
    }

    // MARK: - Dimensions

    private var dimensionsSection: some View {
        HStack(spacing: 14) {
            DetailMetric(icon: "ruler.fill", title: "Height", value: String(format: "%.1f m", pokemon.height), color: themeColor)
            DetailMetric(icon: "scalemass.fill", title: "Weight", value: String(format: "%.1f kg", pokemon.weight), color: themeColor)
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Base Stats", icon: "chart.bar.fill")
            StatRow(name: "HP", value: pokemon.stats.hp, color: .red)
            StatRow(name: "Attack", value: pokemon.stats.attack, color: .orange)
            StatRow(name: "Defense", value: pokemon.stats.defense, color: .blue)
            StatRow(name: "Speed", value: pokemon.stats.speed, color: .green)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Abilities

    private var abilitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Abilities", icon: "sparkles")
            ForEach(pokemon.abilities, id: \.self) { ability in
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(themeColor.opacity(0.18)).frame(width: 32, height: 32)
                        Image(systemName: "bolt.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(themeColor)
                    }
                    Text(ability)
                        .font(.body.weight(.medium))
                    Spacer()
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(themeColor)
            Text(title)
                .font(.title3.weight(.bold))
        }
    }

    // MARK: - Team Button

    private var teamButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                addedToTeam.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: addedToTeam ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(addedToTeam ? "Added to My Team" : "Add to My Team")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: addedToTeam ? [.green, .green.opacity(0.75)] : [themeColor, themeColor.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: (addedToTeam ? Color.green : themeColor).opacity(0.4), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct DetailMetric: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct StatRow: View {
    let name: String
    let value: Int
    let color: Color

    private var progress: Double { min(Double(value) / 120.0, 1.0) }

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .frame(width: 64, alignment: .leading)
                .font(.subheadline.weight(.semibold))
            Text("\(value)")
                .frame(width: 30, alignment: .trailing)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 10)
        }
        .frame(height: 22)
    }
}
