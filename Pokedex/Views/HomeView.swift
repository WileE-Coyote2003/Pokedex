import SwiftUI

struct HomeView: View {

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        VStack(spacing: 0) {

            Text("Popular Pokémon")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
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
