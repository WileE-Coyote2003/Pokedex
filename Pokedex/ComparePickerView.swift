import SwiftUI

/// Screen shown when the user taps the Compare tab.
/// Lets them search the full Pokédex and pick exactly two Pokémon,
/// then pushes to CompareResultView once both are selected.
struct ComparePickerView: View {
    let pokemon: [Pokemon]
    @State private var searchText = ""
    @State private var selected: [Pokemon] = []

    private var filteredPokemon: [Pokemon] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return pokemon }
        return pokemon.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private func isSelected(_ item: Pokemon) -> Bool {
        selected.contains(item)
    }

    private func toggleSelection(_ item: Pokemon) {
        if let idx = selected.firstIndex(of: item) {
            selected.remove(at: idx)
        } else if selected.count < 2 {
            selected.append(item)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Compare Pokémon")
                    .font(.title2.weight(.bold))

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search Pokémon...", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                selectionSummary
            }
            .padding()

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPokemon) { item in
                        let isMaxed = selected.count == 2 && !isSelected(item)
                        Button {
                            toggleSelection(item)
                        } label: {
                            ComparePickCard(pokemon: item, isSelected: isSelected(item), disabled: isMaxed)
                        }
                        .buttonStyle(.plain)
                        .disabled(isMaxed)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 110)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if selected.count == 2 {
                NavigationLink {
                    CompareResultView(pokemonA: selected[0], pokemonB: selected[1])
                } label: {
                    Text("Compare")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(.white)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
                .background(.bar)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectionSummary: some View {
        HStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { index in
                if index < selected.count {
                    SelectedSlot(pokemon: selected[index]) {
                        selected.remove(at: index)
                    }
                } else {
                    EmptySlot(number: index + 1)
                }
            }
        }
    }
}

private struct SelectedSlot: View {
    let pokemon: Pokemon
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: pokemon.imageURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFit()
                } else {
                    Image(systemName: "pawprint.fill").foregroundStyle(.secondary)
                }
            }
            .frame(width: 28, height: 28)

            Text(pokemon.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Spacer(minLength: 0)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(pokemon.primaryType.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct EmptySlot: View {
    let number: Int

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundStyle(.secondary)
            Text("Select Pokémon \(number)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ComparePickCard: View {
    let pokemon: Pokemon
    let isSelected: Bool
    let disabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Image(systemName: "pawprint.fill").foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(pokemon.name)
                    .font(.headline)
                PokemonTypeLabel(type: pokemon.primaryType)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? pokemon.primaryType.color : Color.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 78)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? pokemon.primaryType.color : Color(.quaternaryLabel), lineWidth: isSelected ? 2 : 1)
        }
        .opacity(disabled ? 0.4 : 1)
    }
}

#Preview {
    NavigationStack {
        ComparePickerView(pokemon: Pokemon.sampleData)
    }
}
