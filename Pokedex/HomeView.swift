import SwiftUI

struct HomeView: View {
    let pokemon: [Pokemon]
    @Binding var favorites: Set<Int>
    @State private var searchText = ""

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var displayedPokemon: [Pokemon] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return pokemon }
        return pokemon.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search Pokémon...", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text("Popular Pokémon")
                        .font(.title3.weight(.semibold))

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(displayedPokemon) { item in
                            NavigationLink(value: item) {
                                PokemonCardView(pokemon: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pokédex")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                    }
                    .accessibilityLabel("Menu")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: favorites.isEmpty ? "heart" : "heart.fill")
                    }
                    .accessibilityLabel("Favorites")
                }
            }
            .navigationDestination(for: Pokemon.self) { item in
                PokemonDetailView(pokemon: item, isFavorite: Binding(
                    get: { favorites.contains(item.id) },
                    set: { newValue in
                        var updated = favorites
                        if newValue { updated.insert(item.id) } else { updated.remove(item.id) }
                        favorites = updated
                    }
                ))
            }
            .safeAreaInset(edge: .bottom) {
                AppTabBar(pokemon: pokemon)
            }
        }
    }
}

struct AppTabBar: View {
    let pokemon: [Pokemon]

    var body: some View {
        HStack {
            TabItem(title: "Home", icon: "house.fill", selected: true)
            Spacer()
            TabItem(title: "Search", icon: "magnifyingglass", selected: false)
            Spacer()
            TabItem(title: "Team", icon: "circle.circle", selected: false)
            Spacer()
            NavigationLink {
                ComparePickerView(pokemon: pokemon)
            } label: {
                TabItem(title: "Compare", icon: "person.2.fill", selected: false)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 26)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.bar)
    }
}

struct TabItem: View {
    let title: String
    let icon: String
    let selected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
            Text(title).font(.caption2)
        }
        .foregroundStyle(selected ? .primary : .secondary)
    }
}
