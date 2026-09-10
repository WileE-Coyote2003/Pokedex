import SwiftUI

struct AddPokemonView: View {
    @Environment(\.dismiss) private var dismiss

    let pokemon: [Pokemon]
    let selectionLimit: Int

    @State private var selectedPokemon: [Pokemon]
    @State private var isShowingCapacityAlert = false

    private let onSave: ([Pokemon]) -> Void

    init(
        pokemon: [Pokemon],
        initiallySelectedPokemon: [Pokemon] = [],
        selectionLimit: Int = 6,
        onSave: @escaping ([Pokemon]) -> Void = { _ in }
    ) {
        self.pokemon = pokemon
        self.selectionLimit = selectionLimit
        self.onSave = onSave
        _selectedPokemon = State(initialValue: initiallySelectedPokemon)
    }

    var body: some View {
        NavigationStack {
            PokemonSearchBrowser(pokemon: pokemon) {
                selectionCount
            } row: { pokemon in
                AddPokemonRow(
                    pokemon: pokemon,
                    isSelected: isSelected(pokemon)
                ) {
                    toggleSelection(for: pokemon)
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
                    Button("Add") {
                        addToTeam()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                }
            }
            .alert("Team Limit Reached", isPresented: $isShowingCapacityAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A Trainer can carry a maximum of 6 Pokémon at one time.")
            }
        }
    }

    private var selectionCount: some View {
        HStack {
            Text("Selected")
                .font(.subheadline.weight(.semibold))

            Spacer()

            Text("\(selectedPokemon.count) / \(selectionLimit)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    selectedPokemon.count > selectionLimit ? .red : .secondary
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func isSelected(_ pokemon: Pokemon) -> Bool {
        selectedPokemon.contains { $0.id == pokemon.id }
    }

    private func toggleSelection(for pokemon: Pokemon) {
        if isSelected(pokemon) {
            selectedPokemon.removeAll { $0.id == pokemon.id }
        } else {
            selectedPokemon.append(pokemon)
        }
    }

    private func addToTeam() {
        guard selectedPokemon.count <= selectionLimit else {
            isShowingCapacityAlert = true
            return
        }

        onSave(selectedPokemon)
        dismiss()
    }
}

private struct AddPokemonRow: View {
    let pokemon: Pokemon
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 68, height: 68)
            .accessibilityLabel("\(pokemon.name) official artwork")

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
            .accessibilityLabel(isSelected ? "Remove \(pokemon.name)" : "Add \(pokemon.name)")
        }
        .frame(minHeight: 78)
        .contentShape(Rectangle())
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
