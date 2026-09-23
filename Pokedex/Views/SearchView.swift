import SwiftUI

struct SearchView: View {
    private let pokemon: [Pokemon]
    private let searchMode: PokemonSearchMode

    init(
        pokemon: [Pokemon] = [],
        searchMode: PokemonSearchMode = .browse
    ) {
        self.pokemon = pokemon
        self.searchMode = searchMode
    }

    var body: some View {
        PokemonSearchBrowser(
            pokemon: pokemon,
            mode: searchMode,
            rowSpacing: 10,
            showsDividers: false
        ) {
            EmptyView()
        } row: { pokemon in
            NavigationLink {
                PokemonDetailView(pokemon: pokemon)
            } label: {
                PokemonSearchResultCard(pokemon: pokemon)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows details for \(pokemon.name)")
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SearchView(
            pokemon: samplePokemon,
            searchMode: .local
        )
    }
}
