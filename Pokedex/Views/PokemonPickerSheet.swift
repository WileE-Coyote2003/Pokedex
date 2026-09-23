import SwiftUI

struct PokemonPickerSheet: View {
    let title: String
    let excludedPokemonID: Int?
    let onSelect: (Pokemon) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var availablePokemon: [Pokemon] {
        samplePokemon.filter { pokemon in
            pokemon.id != excludedPokemonID
        }
    }

    private var filteredPokemon: [Pokemon] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if query.isEmpty {
            return availablePokemon
        }

        return availablePokemon.filter { pokemon in
            pokemon.name.lowercased().contains(query) ||
            pokemon.formattedNumber
                .lowercased()
                .contains(query) ||
            String(pokemon.id).contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredPokemon) { pokemon in
                Button {
                    onSelect(pokemon)
                    dismiss()
                } label: {
                    HStack(spacing: 14) {

                        AsyncImage(url: pokemon.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()

                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)

                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(pokemon.name)
                                .font(.headline)

                            Text(pokemon.formattedNumber)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(pokemon.types.joined(separator: " / "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: "Search Pokémon"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonPickerSheet(
        title: "Select Pokémon",
        excludedPokemonID: nil
    ) { pokemon in
        print(pokemon.name)
    }
}