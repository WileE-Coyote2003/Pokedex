import SwiftUI

struct ComparePickerView: View {
    let pokemon: [Pokemon]
    @State private var searchText = ""
    @State private var selected: [Pokemon] = []

    private var filteredPokemon: [Pokemon] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return pokemon }
        return pokemon.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose two Pokémon to compare")
                    .font(.headline)

                searchField
                selectionSummary
            }
            .padding()

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPokemon) { item in
                        let unavailable = selected.count == 2 && !selected.contains(item)

                        Button {
                            toggleSelection(item)
                        } label: {
                            ComparePickCard(
                                pokemon: item,
                                isSelected: selected.contains(item),
                                isUnavailable: unavailable
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(unavailable)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if selected.count == 2 {
                NavigationLink {
                    CompareResultView(
                        leftPokemon: selected[0],
                        rightPokemon: selected[1]
                    )
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
                .accessibilityLabel("Compare \(selected[0].name) and \(selected[1].name)")
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search Pokémon...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var selectionSummary: some View {
        HStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { index in
                if index < selected.count {
                    SelectedCompareSlot(pokemon: selected[index]) {
                        selected.remove(at: index)
                    }
                } else {
                    EmptyCompareSlot(number: index + 1)
                }
            }
        }
    }

    private func toggleSelection(_ item: Pokemon) {
        if let index = selected.firstIndex(of: item) {
            selected.remove(at: index)
        } else if selected.count < 2 {
            selected.append(item)
        }
    }
}

private struct SelectedCompareSlot: View {
    let pokemon: Pokemon
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: pokemon.imageURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFit()
                } else {
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.secondary)
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
            .accessibilityLabel("Remove \(pokemon.name)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(pokemonTypeColor(for: pokemon.primaryType).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct EmptyCompareSlot: View {
    let number: Int

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
            Text("Select Pokémon \(number)")
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
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
    let isUnavailable: Bool

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(pokemon.name)
                    .font(.headline)

                HStack(spacing: 5) {
                    Text(pokemon.typeIcon)
                    Text(pokemon.primaryType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Text(pokemon.formattedNumber)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? pokemonTypeColor(for: pokemon.primaryType) : Color.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 78)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? pokemonTypeColor(for: pokemon.primaryType) : Color(.separator),
                    lineWidth: isSelected ? 2 : 0.5
                )
        }
        .opacity(isUnavailable ? 0.4 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pokemon.name), \(pokemon.primaryType)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

#Preview {
    NavigationStack {
        ComparePickerView(pokemon: samplePokemon)
    }
}
