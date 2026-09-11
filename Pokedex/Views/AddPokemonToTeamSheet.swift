import SwiftUI
import SwiftData

struct AddPokemonToTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \PokemonTeam.createdAt, order: .reverse)
    private var teams: [PokemonTeam]

    let pokemon: Pokemon

    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if teams.isEmpty {
                    emptyState
                } else {
                    teamList
                }
            }
            .navigationTitle("Add \(pokemon.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Couldn’t Add Pokémon", isPresented: isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
        }
    }

    private var teamList: some View {
        List(teams) { team in
            TeamSelectionRow(
                team: team,
                pokemon: pokemon
            ) {
                addPokemon(to: team)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Teams Yet", systemImage: "person.3")
        } description: {
            Text("Create a team before adding \(pokemon.name).")
        } actions: {
            NavigationLink {
                TeamCreate()
            } label: {
                Label("Create New Team", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    private func addPokemon(to team: PokemonTeam) {
        do {
            try PokemonTeamMembership.add(
                pokemon,
                to: team,
                in: modelContext
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct TeamSelectionRow: View {
    let team: PokemonTeam
    let pokemon: Pokemon
    let action: () -> Void

    private var isAlreadyMember: Bool {
        PokemonTeamMembership.contains(pokemon, in: team)
    }

    private var isFull: Bool {
        team.members.count >= PokemonTeam.capacity
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(team.pokeballAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(team.members.count) / \(PokemonTeam.capacity) Pokémon")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isAlreadyMember {
                    Label("Added", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                } else if isFull {
                    Text("Full")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isAlreadyMember || isFull)
        .accessibilityLabel("\(team.name), \(team.members.count) of \(PokemonTeam.capacity) Pokémon")
        .accessibilityValue(
            isAlreadyMember ? "Already added" : isFull ? "Team full" : "Available"
        )
    }
}

#Preview {
    AddPokemonToTeamSheet(pokemon: samplePokemon[0])
        .modelContainer(
            for: [PokemonTeam.self, PokemonTeamMember.self],
            inMemory: true
        )
}
