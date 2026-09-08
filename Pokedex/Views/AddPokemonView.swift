import SwiftUI

struct AddPokemonView: View {
    @Environment(\.dismiss) private var dismiss

    let pokemon: [Pokemon]
    let selectionLimit: Int

    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var selectedPokemonIDs: Set<Int>

    private var filters: [String] {
        ["All"] + Pokemon.allTypes
    }

    init(
        pokemon: [Pokemon],
        initiallySelectedIDs: Set<Int> = [],
        selectionLimit: Int = 6
    ) {
        self.pokemon = pokemon
        self.selectionLimit = selectionLimit
        _selectedPokemonIDs = State(initialValue: initiallySelectedIDs)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                typeFilters
                    .padding(.top, 12)

                if filteredPokemon.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPokemon) { pokemon in
                                AddPokemonRow(
                                    pokemon: pokemon,
                                    isSelected: selectedPokemonIDs.contains(pokemon.id),
                                    isSelectionDisabled: isSelectionDisabled(for: pokemon)
                                ) {
                                    toggleSelection(for: pokemon)
                                }

                                Divider()
                                    .padding(.leading, 104)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Add Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search Pokémon...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color(uiColor: .secondarySystemBackground), in: Capsule())
    }

    private var typeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedType = filter
                    } label: {
                        Text(filter)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedType == filter ? .white : .secondary)
                            .padding(.horizontal, 18)
                            .frame(height: 40)
                            .background(
                                selectedType == filter
                                    ? Color.red
                                    : Color(uiColor: .secondarySystemBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedType == filter ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var filteredPokemon: [Pokemon] {
        pokemon.filter { pokemon in
            let matchesSearch = searchText.isEmpty
                || pokemon.name.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedType == "All"
                || pokemon.types.contains { $0.caseInsensitiveCompare(selectedType) == .orderedSame }
            return matchesSearch && matchesType
        }
    }

    private func isSelectionDisabled(for pokemon: Pokemon) -> Bool {
        !selectedPokemonIDs.contains(pokemon.id) && selectedPokemonIDs.count >= selectionLimit
    }

    private func toggleSelection(for pokemon: Pokemon) {
        if selectedPokemonIDs.contains(pokemon.id) {
            selectedPokemonIDs.remove(pokemon.id)
        } else if selectedPokemonIDs.count < selectionLimit {
            selectedPokemonIDs.insert(pokemon.id)
        }
    }
}

private struct AddPokemonRow: View {
    let pokemon: Pokemon
    let isSelected: Bool
    let isSelectionDisabled: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Intentionally empty: artwork will be added when the picker uses live data.
            Color.clear
                .frame(width: 68, height: 68)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                Text(pokemon.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    ForEach(Array(pokemon.types.enumerated()), id: \.offset) { index, type in
                        PokemonTypeTag(
                            type: type,
                            icon: index == 0 ? pokemon.typeIcon : nil
                        )
                    }

                    Text(pokemon.formattedNumber)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Button(action: action) {
                Image(systemName: isSelected ? "checkmark" : "plus")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(width: 34, height: 34)
                    .background(.clear, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.red, lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)
            .disabled(isSelectionDisabled)
            .opacity(isSelectionDisabled ? 0.35 : 1)
            .accessibilityLabel(isSelected ? "Remove \(pokemon.name)" : "Add \(pokemon.name)")
        }
        .frame(minHeight: 78)
        .contentShape(Rectangle())
        .opacity(isSelectionDisabled ? 0.65 : 1)
    }
}

private struct PokemonTypeTag: View {
    let type: String
    let icon: String?

    var body: some View {
        Text(icon.map { "\($0) \(type)" } ?? type)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var backgroundColor: Color {
        switch type.lowercased() {
        case "fire": .orange.opacity(0.22)
        case "water": .blue.opacity(0.18)
        case "grass": .green.opacity(0.2)
        case "electric": .yellow.opacity(0.28)
        case "poison": .purple.opacity(0.2)
        case "flying": .indigo.opacity(0.17)
        default: .secondary.opacity(0.13)
        }
    }

    private var foregroundColor: Color {
        switch type.lowercased() {
        case "fire": .red
        case "water": .blue
        case "grass": .green
        case "electric": .orange
        case "poison": .purple
        case "flying": .indigo
        default: .secondary
        }
    }
}

#Preview {
    AddPokemonView(pokemon: samplePokemon)
}
