//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var teams: [PokemonTeam]
    @Query private var favorites: [FavoritePokemon]

    let pokemon: Pokemon
    @State private var isShowingTeamPicker = false
    @State private var isShowingFavoriteSaveError = false
    @State private var speciesDetails: PokemonSpeciesDetails?
    @State private var isLoadingSpecies = true
    @State private var speciesErrorMessage: String?

    private let service = PokemonService()

    private var favorite: FavoritePokemon? {
        favorites.first { $0.pokemonID == pokemon.id }
    }

    private var isFavorite: Bool { favorite != nil }

    private var themeColor: Color { pokemon.primaryType.color }

    private var teamMembershipCount: Int {
        teams.count {
            PokemonTeamMembership.contains(pokemon, in: $0)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroSection
                speciesSection
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
                        toggleFavorite()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .sheet(isPresented: $isShowingTeamPicker) {
            AddPokemonToTeamSheet(pokemon: pokemon)
        }
        .alert("Couldn’t Update Favorites", isPresented: $isShowingFavoriteSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your saved Pokémon couldn’t be updated. Please try again.")
        }
        .task(id: pokemon.speciesName) {
            await loadSpeciesDetails()
        }
    }

    // MARK: - Species

    private var speciesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Species & Origin", icon: "globe.asia.australia.fill")

            if isLoadingSpecies {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading species information...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let speciesDetails {
                Text(speciesDetails.genus)
                    .font(.headline)

                Text(speciesDetails.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    SpeciesFact(
                        title: "Region",
                        value: speciesDetails.region,
                        icon: "map.fill",
                        color: themeColor
                    )
                    SpeciesFact(
                        title: "Generation",
                        value: speciesDetails.generation,
                        icon: "clock.fill",
                        color: themeColor
                    )
                }

                if let habitat = speciesDetails.habitat {
                    SpeciesFact(
                        title: "Habitat",
                        value: habitat,
                        icon: "leaf.fill",
                        color: themeColor
                    )
                }

                speciesBadges(for: speciesDetails)
            } else if let speciesErrorMessage {
                VStack(alignment: .leading, spacing: 10) {
                    Text(speciesErrorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Try Again") {
                        Task {
                            await loadSpeciesDetails()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(themeColor)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }

    @ViewBuilder
    private func speciesBadges(
        for details: PokemonSpeciesDetails
    ) -> some View {
        if details.isBaby || details.isLegendary || details.isMythical {
            HStack(spacing: 8) {
                if details.isBaby {
                    speciesBadge("Baby", icon: "figure.child")
                }
                if details.isLegendary {
                    speciesBadge("Legendary", icon: "star.fill")
                }
                if details.isMythical {
                    speciesBadge("Mythical", icon: "sparkles")
                }
            }
        }
    }

    private func speciesBadge(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(themeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(themeColor.opacity(0.14), in: Capsule())
    }

    @MainActor
    private func loadSpeciesDetails() async {
        isLoadingSpecies = true
        speciesErrorMessage = nil

        do {
            speciesDetails = try await service.fetchSpeciesDetails(for: pokemon)
        } catch is CancellationError {
            return
        } catch {
            speciesDetails = nil
            speciesErrorMessage = "Species information is unavailable right now."
        }

        isLoadingSpecies = false
    }

    private func toggleFavorite() {
        if let favorite {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(FavoritePokemon(pokemon: pokemon))
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            isShowingFavoriteSaveError = true
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

            Text(pokemon.formattedNumber)
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
            isShowingTeamPicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: teamMembershipCount > 0 ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(teamButtonTitle)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: teamMembershipCount > 0
                        ? [.green, .green.opacity(0.75)]
                        : [themeColor, themeColor.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: (teamMembershipCount > 0 ? Color.green : themeColor).opacity(0.4),
                radius: 10,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }

    private var teamButtonTitle: String {
        switch teamMembershipCount {
        case 0:
            "Add to My Team"
        case 1:
            "Added to 1 Team"
        default:
            "Added to \(teamMembershipCount) Teams"
        }
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

private struct SpeciesFact: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .background(
            color.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
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

private struct PokemonTypeLabel: View {
    let type: String
    let filled: Bool

    var body: some View {
        Text(type)
            .font(.caption.weight(.bold))
            .foregroundStyle(filled ? .white : type.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(filled ? type.color : type.color.opacity(0.15), in: Capsule())
    }
}

private extension String {
    var color: Color {
        switch lowercased() {
        case "fire": .orange
        case "water": .blue
        case "grass": .green
        case "electric": .yellow
        case "psychic": .pink
        case "poison": .purple
        case "flying": .cyan
        case "bug": .mint
        case "fighting": .red
        case "ground": .brown
        case "rock": .gray
        case "ghost": .indigo
        case "ice": .teal
        case "dragon": .indigo
        case "dark": .black
        case "steel": .gray
        case "fairy": .pink
        default: .secondary
        }
    }
}
