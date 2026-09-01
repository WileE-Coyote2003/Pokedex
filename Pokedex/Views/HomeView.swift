import SwiftUI

struct HomeView: View {

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        VStack(spacing: 0) {

            // Search button
            NavigationLink {
                SearchView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    Text("Search Pokémon")
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.top, 10)

            // Pokémon cards
            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: 14
                ) {
                    ForEach(samplePokemon) { pokemon in
                        NavigationLink {
                            PokemonDetailView(pokemon: pokemon)
                        } label: {
                            PokemonCardView(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // Menu action
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Favorites action
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}