import SwiftUI

struct AddPokemonView: View {
    @Environment(\.dismiss) private var dismiss

    let pokemon: [Pokemon]
    let selectionLimit: Int

    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var selectedPokemon: [Pokemon]
    @State private var loadedPokemon: [Pokemon]
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var paginationErrorMessage: String?
    @State private var nextOffset: Int?
    @State private var refreshToken = 0
    @State private var isShowingCapacityAlert = false

    private let service = PokemonService()
    private let onSave: ([Pokemon]) -> Void

    private var filters: [String] {
        ["All"] + Pokemon.allTypes
    }

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
        _loadedPokemon = State(initialValue: pokemon)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                typeFilters
                    .padding(.top, 12)

                selectionCount

                if isLoading {
                    ProgressView("Loading Pokémon...")
                        .frame(maxHeight: .infinity)
                } else if let errorMessage {
                    ContentUnavailableView {
                        Label("Unable to Load Pokémon", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            refreshToken += 1
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .frame(maxHeight: .infinity)
                } else if loadedPokemon.isEmpty {
                    ContentUnavailableView(
                        "No Pokémon Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try another name, number, or type.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(loadedPokemon) { pokemon in
                                AddPokemonRow(
                                    pokemon: pokemon,
                                    isSelected: isSelected(pokemon)
                                ) {
                                    toggleSelection(for: pokemon)
                                }

                                Divider()
                                    .padding(.leading, 104)
                            }

                            paginationFooter
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Add Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: requestID) {
                await loadPokemon()
            }
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

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Name or Pokédex number", text: $searchText)
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

    @ViewBuilder
    private var paginationFooter: some View {
        if let paginationErrorMessage {
            Button("Try Loading More") {
                Task {
                    await loadNextPage()
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.red)
            .padding(.vertical, 20)
            .accessibilityHint(paginationErrorMessage)
        } else if nextOffset != nil {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .task {
                    await loadNextPage()
                }
        }
    }

    private var requestID: String {
        "\(normalizedSearch)|\(selectedType)|\(refreshToken)"
    }

    private var normalizedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadPokemon() async {
        isLoading = true
        isLoadingMore = false
        errorMessage = nil
        paginationErrorMessage = nil
        nextOffset = nil

        do {
            if !normalizedSearch.isEmpty {
                try await Task.sleep(for: .milliseconds(350))

                let result: Pokemon
                if let pokedexNumber = Int(normalizedSearch) {
                    result = try await service.fetchPokemon(
                        pokedexNumber: pokedexNumber
                    )
                } else {
                    result = try await service.fetchPokemon(name: normalizedSearch)
                }

                loadedPokemon = matchesSelectedType(result) ? [result] : []
            } else if selectedType != "All" {
                loadedPokemon = try await service.fetchPokemon(type: selectedType)
            } else {
                let page = try await service.fetchPokemon()
                loadedPokemon = page.pokemon
                nextOffset = page.nextOffset
            }
        } catch is CancellationError {
            return
        } catch {
            loadedPokemon = []
            errorMessage = "Check your connection or try a different Pokémon."
        }

        isLoading = false
    }

    private func loadNextPage() async {
        guard let offset = nextOffset,
              !isLoadingMore,
              normalizedSearch.isEmpty,
              selectedType == "All" else {
            return
        }

        isLoadingMore = true
        paginationErrorMessage = nil

        do {
            let page = try await service.fetchPokemon(limit: 20, offset: offset)
            let loadedIDs = Set(loadedPokemon.map(\.id))
            loadedPokemon.append(
                contentsOf: page.pokemon.filter { !loadedIDs.contains($0.id) }
            )
            nextOffset = page.nextOffset
        } catch is CancellationError {
            isLoadingMore = false
            return
        } catch {
            paginationErrorMessage = "Check your connection and try again."
        }

        isLoadingMore = false
    }

    private func matchesSelectedType(_ pokemon: Pokemon) -> Bool {
        selectedType == "All" || pokemon.types.contains {
            $0.caseInsensitiveCompare(selectedType) == .orderedSame
        }
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
