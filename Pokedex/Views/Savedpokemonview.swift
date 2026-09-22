import SwiftUI
import SwiftData

/// Shows the Pokémon the user has saved (via the heart button on
/// `PokemonDetailView`). Favorites are persisted locally with SwiftData.
struct SavedPokemonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoritePokemon.savedAt, order: .reverse)
    private var favorites: [FavoritePokemon]

    @State private var isShowingSaveError = false

    var body: some View {
        Group {
            if favorites.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(favorites) { favorite in
                            savedRow(for: favorite)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Saved Pokémon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn’t Remove Favorite", isPresented: $isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The Pokémon couldn’t be removed from your favorites. Please try again.")
        }
    }

    // MARK: - Row

    private func savedRow(for favorite: FavoritePokemon) -> some View {
        let pokemon = favorite.pokemon

        return HStack(spacing: 10) {
            NavigationLink {
                PokemonDetailView(pokemon: pokemon)
            } label: {
                PokemonSearchResultCard(pokemon: pokemon)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows details for \(pokemon.name)")

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    remove(favorite)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Remove \(pokemon.name) from saved Pokémon")
        }
    }

    private func remove(_ favorite: FavoritePokemon) {
        modelContext.delete(favorite)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            isShowingSaveError = true
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

#Preview("Empty State") {
    NavigationStack {
        SavedPokemonView()
    }
    .modelContainer(for: FavoritePokemon.self, inMemory: true)
}
