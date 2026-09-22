import SwiftUI

struct HomeView: View {
    @State private var featuredPokemon: [Pokemon]
    @State private var isLoading: Bool
    @State private var errorMessage: String?

    private let service = PokemonService()
    private let previewPokemon: [Pokemon]?
    private let featuredPokedexNumbers = [25, 6, 1, 7, 94, 143, 448, 700]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(pokemon: [Pokemon]? = nil) {
        previewPokemon = pokemon
        _featuredPokemon = State(initialValue: pokemon ?? [])
        _isLoading = State(initialValue: pokemon == nil)
        _errorMessage = State(initialValue: nil)
    }

    var body: some View {
        Group {
            if isLoading && featuredPokemon.isEmpty {
                ProgressView("Loading featured Pokémon...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage, featuredPokemon.isEmpty {
                ContentUnavailableView {
                    Label(
                        "Unable to Load Featured Pokémon",
                        systemImage: "wifi.exclamationmark"
                    )
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await loadFeaturedPokemon()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else if featuredPokemon.isEmpty {
                ContentUnavailableView(
                    "No Featured Pokémon",
                    systemImage: "sparkles",
                    description: Text("Check back again soon.")
                )
            } else {
                pokemonGrid
            }
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SavedPokemonView()
                } label: {
                    Image(systemName: "heart")
                }
                .accessibilityLabel("Saved Pokémon")
            }
        }
        .task {
            guard previewPokemon == nil, featuredPokemon.isEmpty else {
                return
            }

            await loadFeaturedPokemon()
        }
    }

    private var pokemonGrid: some View {
        ScrollView {
            Text("Featured Pokémon")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)

            LazyVGrid(
                columns: columns,
                spacing: 14
            ) {
                ForEach(featuredPokemon) { pokemon in
                    NavigationLink {
                        PokemonDetailView(pokemon: pokemon)
                    } label: {
                        PokemonCardView(pokemon: pokemon)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Shows details for \(pokemon.name)")
                }
            }
            .padding()
        }
        .refreshable {
            guard previewPokemon == nil else {
                return
            }

            await loadFeaturedPokemon()
        }
    }

    @MainActor
    private func loadFeaturedPokemon() async {
        if featuredPokemon.isEmpty {
            isLoading = true
        }
        errorMessage = nil

        do {
            featuredPokemon = try await service.fetchPokemon(
                pokedexNumbers: featuredPokedexNumbers
            )
        } catch is CancellationError {
            isLoading = false
            return
        } catch {
            errorMessage = "Check your connection and try again."
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        HomeView(pokemon: samplePokemon)
    }
}
