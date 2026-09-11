import SwiftUI

enum PokemonSearchMode: Equatable {
    case browse
    case queryOnly
    case local
}

struct PokemonSearchBrowser<Header: View, Row: View>: View {
    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var loadedPokemon: [Pokemon]
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var paginationErrorMessage: String?
    @State private var nextOffset: Int?
    @State private var refreshToken = 0
    @State private var requestGeneration = 0

    private let service = PokemonService()
    private let initialPokemon: [Pokemon]
    private let mode: PokemonSearchMode
    private let rowSpacing: CGFloat
    private let showsDividers: Bool
    private let header: () -> Header
    private let row: (Pokemon) -> Row

    private var filters: [String] {
        ["All"] + Pokemon.allTypes
    }

    init(
        pokemon: [Pokemon],
        mode: PokemonSearchMode = .browse,
        rowSpacing: CGFloat = 0,
        showsDividers: Bool = true,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder row: @escaping (Pokemon) -> Row
    ) {
        _loadedPokemon = State(initialValue: pokemon)
        initialPokemon = pokemon
        self.mode = mode
        self.rowSpacing = rowSpacing
        self.showsDividers = showsDividers
        self.header = header
        self.row = row
    }

    var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding(.horizontal, 20)
                .padding(.top, 12)

            typeFilters
                .padding(.top, 12)

            header()

            results
        }
        .task(id: requestID) {
            await loadPokemon()
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

    @ViewBuilder
    private var results: some View {
        if mode == .queryOnly && normalizedSearch.isEmpty {
            ContentUnavailableView(
                "Search for a Pokémon",
                systemImage: "magnifyingglass",
                description: Text("Enter a name or Pokédex number to begin.")
            )
            .frame(maxHeight: .infinity)
        } else if isLoading {
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
                LazyVStack(spacing: rowSpacing) {
                    ForEach(loadedPokemon) { pokemon in
                        row(pokemon)

                        if showsDividers {
                            Divider()
                                .padding(.leading, 104)
                        }
                    }

                    paginationFooter
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
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
        requestGeneration += 1
        let generation = requestGeneration

        let query = normalizedSearch
        let type = selectedType

        if mode == .queryOnly && query.isEmpty {
            loadedPokemon = []
            isLoading = false
            errorMessage = nil
            paginationErrorMessage = nil
            nextOffset = nil
            return
        }

        if mode == .local {
            loadedPokemon = initialPokemon.filter { pokemon in
                let matchesName = query.isEmpty
                    || pokemon.name.localizedCaseInsensitiveContains(query)
                    || String(pokemon.id) == query
                return matchesName && matchesSelectedType(pokemon, type: type)
            }
            isLoading = false
            errorMessage = nil
            paginationErrorMessage = nil
            nextOffset = nil
            return
        }

        isLoading = true
        isLoadingMore = false
        errorMessage = nil
        paginationErrorMessage = nil
        nextOffset = nil

        do {
            if !query.isEmpty {
                try await Task.sleep(for: .milliseconds(350))
                try Task.checkCancellation()

                let result: Pokemon
                if let pokedexNumber = Int(query) {
                    result = try await service.fetchPokemon(pokedexNumber: pokedexNumber)
                } else {
                    result = try await service.fetchPokemon(name: query)
                }

                try Task.checkCancellation()

                guard generation == requestGeneration else {
                    return
                }

                loadedPokemon = matchesSelectedType(result, type: type) ? [result] : []
            } else if type != "All" {
                let pokemon = try await service.fetchPokemon(type: type)
                try Task.checkCancellation()

                guard generation == requestGeneration else {
                    return
                }

                loadedPokemon = pokemon.filter { matchesSelectedType($0, type: type) }
            } else {
                let page = try await service.fetchPokemon()
                try Task.checkCancellation()

                guard generation == requestGeneration else {
                    return
                }

                loadedPokemon = page.pokemon
                nextOffset = page.nextOffset
            }
        } catch is CancellationError {
            return
        } catch PokemonServiceError.notFound {
            guard generation == requestGeneration else {
                return
            }

            loadedPokemon = []
        } catch {
            guard generation == requestGeneration else {
                return
            }

            loadedPokemon = []
            errorMessage = "Check your connection and try again."
        }

        guard generation == requestGeneration else {
            return
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

        let generation = requestGeneration

        isLoadingMore = true
        paginationErrorMessage = nil

        do {
            let page = try await service.fetchPokemon(limit: 20, offset: offset)
            try Task.checkCancellation()

            guard generation == requestGeneration else {
                isLoadingMore = false
                return
            }

            let loadedIDs = Set(loadedPokemon.map(\.id))
            loadedPokemon.append(
                contentsOf: page.pokemon.filter { !loadedIDs.contains($0.id) }
            )
            nextOffset = page.nextOffset
        } catch is CancellationError {
            isLoadingMore = false
            return
        } catch {
            guard generation == requestGeneration else {
                isLoadingMore = false
                return
            }

            paginationErrorMessage = "Check your connection and try again."
        }

        isLoadingMore = false
    }

    private func matchesSelectedType(_ pokemon: Pokemon, type: String) -> Bool {
        type == "All"
            || pokemon.primaryType.caseInsensitiveCompare(type) == .orderedSame
    }
}