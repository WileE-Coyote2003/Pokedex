import SwiftUI

struct SearchView: View {

    @State private var searchText = ""
    @State private var selectedType: String?

    private var availableTypes: [String] {
        Pokemon.allTypes
    }

    private var searchResults: [Pokemon] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return samplePokemon.filter { pokemon in
            let matchesName = query.isEmpty
                || pokemon.name.localizedCaseInsensitiveContains(query)
            let matchesType = selectedType.map { selectedType in
                pokemon.types.contains {
                    $0.caseInsensitiveCompare(selectedType) == .orderedSame
                }
            } ?? true

            return matchesName && matchesType
        }
    }

    private var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedType != nil
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TypeFilterChip(
                        title: "All",
                        color: .red,
                        isSelected: selectedType == nil
                    ) {
                        selectedType = nil
                    }

                    ForEach(availableTypes, id: \.self) { type in
                        TypeFilterChip(
                            title: type,
                            color: pokemonTypeColor(for: type),
                            isSelected: selectedType == type
                        ) {
                            selectedType = type
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .accessibilityLabel("Pokémon type filter")

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(hasActiveFilters
                         ? "Results (\(searchResults.count))"
                         : "All Pokémon (\(searchResults.count))")
                        .font(.title3)
                        .fontWeight(.bold)

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
                .padding()
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TypeFilterChip: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? color : .secondary)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(
                    isSelected ? color.opacity(0.18) : Color(.secondarySystemBackground),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(isSelected ? color : .clear, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) type")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
