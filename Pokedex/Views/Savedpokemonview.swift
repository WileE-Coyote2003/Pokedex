import SwiftUI

/// Shows the Pokémon the user has saved (via the heart button on
/// `PokemonDetailView`). Backed by `SavedPokemonStore`, which is in-memory
/// only — nothing is persisted, and there is no networking involved.
struct SavedPokemonView: View {
    @Environment(SavedPokemonStore.self) private var savedStore

    var body: some View {
        Group {
            if savedStore.savedPokemon.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(savedStore.savedPokemon) { pokemon in
                            savedRow(for: pokemon)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Saved Pokémon")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Row

    private func savedRow(for pokemon: Pokemon) -> some View {
        HStack(spacing: 10) {
            NavigationLink {
                PokemonDetailView(pokemon: pokemon)
            } label: {
                PokemonSearchResultCard(pokemon: pokemon)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows details for \(pokemon.name)")

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    savedStore.remove(pokemon)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Remove \(pokemon.name) from saved Pokémon")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Saved Pokémon",
            systemImage: "heart",
            description: Text("Pokémon you save will appear on this page.")
        )
    }
}

#Preview("With Saved Pokémon") {
    NavigationStack {
        SavedPokemonView()
    }
    .environment(SavedPokemonStore(savedPokemon: Array(samplePokemon.prefix(4))))
}

#Preview("Empty State") {
    NavigationStack {
        SavedPokemonView()
    }
    .environment(SavedPokemonStore())
}