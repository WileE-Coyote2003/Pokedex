import SwiftUI

struct SearchView: View {

    @State private var searchText = ""

    private var searchResults: [Pokemon] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return []
        }

        return samplePokemon.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    "Search Pokémon",
                    text: $searchText
                )

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    // Results
                    if !searchText
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty {

                        Text("Results (\(searchResults.count))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 10)

                        if searchResults.isEmpty {

                            Text("No Pokémon found")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 30)

                        } else {

                            LazyVStack(spacing: 10) {

                                ForEach(searchResults) { pokemon in

                                    NavigationLink {
                                        PokemonDetailView(
                                            pokemon: pokemon
                                        )
                                    } label: {
                                        PokemonSearchResultCard(
                                            pokemon: pokemon
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}