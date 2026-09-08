import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EditTeamView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var team: PokemonTeam
    let capacity: Int

    @State private var draftTeamName: String
    @State private var draftMembers: [Pokemon]
    @State private var draggedMember: Pokemon?
    @State private var isShowingSaveError = false

    init(team: PokemonTeam, capacity: Int = 6) {
        self.team = team
        self.capacity = capacity
        _draftTeamName = State(initialValue: team.name)
        _draftMembers = State(initialValue: team.sortedMembers.map(\.pokemon))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Team Name")
                        .font(.headline)

                    HStack(spacing: 12) {
                        TextField("Team name", text: $draftTeamName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)

                        Image(systemName: "pencil")
                            .foregroundStyle(.primary)
                            .accessibilityHidden(true)
                    }
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(.white, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(Color.secondary.opacity(0.28), lineWidth: 1)
                    }
                    .padding(.top, 10)

                    Text("Pokémon (\(draftMembers.count) / \(capacity))")
                        .font(.headline)
                        .padding(.top, 30)
                        .padding(.bottom, 12)

                    memberCard

                    Button(role: .destructive) {
                        // Team deletion will be connected when persistence is added.
                    } label: {
                        Text("Delete Team")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .overlay {
                                Capsule()
                                    .stroke(.red, lineWidth: 1.5)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 32)

                    Text("You can drag to reorder your Pokémon.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Edit Team")
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
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .disabled(trimmedTeamName.isEmpty)
                }
            }
        }
        .alert("Couldn’t Save Team", isPresented: $isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your team changes couldn’t be saved. Please try again.")
        }
    }

    private var memberCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(draftMembers.enumerated()), id: \.element.id) { index, pokemon in
                EditTeamMemberRow(pokemon: pokemon) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        draftMembers.removeAll { $0.id == pokemon.id }
                    }
                }
                .onDrag {
                    draggedMember = pokemon
                    return NSItemProvider(object: String(pokemon.id) as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: TeamMemberDropDelegate(
                        destination: pokemon,
                        members: $draftMembers,
                        draggedMember: $draggedMember
                    )
                )

                if index < draftMembers.count - 1 {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.secondary.opacity(0.24), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.035), radius: 5, y: 2)
    }

    private var trimmedTeamName: String {
        draftTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveChanges() {
        let draftPokemonIDs = Set(draftMembers.map(\.id))
        let removedMembers = team.members.filter {
            !draftPokemonIDs.contains($0.pokemonID)
        }

        team.name = trimmedTeamName
        team.members.removeAll {
            !draftPokemonIDs.contains($0.pokemonID)
        }

        for member in removedMembers {
            modelContext.delete(member)
        }

        for (position, pokemon) in draftMembers.enumerated() {
            team.members.first { $0.pokemonID == pokemon.id }?.position = position
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            isShowingSaveError = true
        }
    }
}

private struct EditTeamMemberRow: View {
    let pokemon: Pokemon
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onRemove) {
                Image(systemName: "minus")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.red, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(pokemon.name)")

            PokemonArtworkView(pokemon: pokemon)
                .frame(width: 62, height: 68)

            VStack(alignment: .leading, spacing: 7) {
                Text(pokemon.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    ForEach(Array(pokemon.types.enumerated()), id: \.offset) { index, type in
                        EditTeamTypeBadge(
                            type: type,
                            icon: index == 0 ? pokemon.typeIcon : nil
                        )
                    }
                }
            }

            Spacer(minLength: 4)

            Image(systemName: "line.3.horizontal")
                .font(.headline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Drag to reorder \(pokemon.name)")
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 76)
    }
}

private struct TeamMemberDropDelegate: DropDelegate {
    let destination: Pokemon
    @Binding var members: [Pokemon]
    @Binding var draggedMember: Pokemon?

    func dropEntered(info: DropInfo) {
        guard let draggedMember,
              draggedMember != destination,
              let sourceIndex = members.firstIndex(of: draggedMember),
              let destinationIndex = members.firstIndex(of: destination) else {
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            members.move(
                fromOffsets: IndexSet(integer: sourceIndex),
                toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex
            )
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedMember = nil
        return true
    }
}

private struct EditTeamTypeBadge: View {
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
    let team = PokemonTeam(
        name: "Kanto Champions",
        pokeballAssetName: "pokeball-red"
    )
    team.members = Array(samplePokemon.prefix(6)).enumerated().map { position, pokemon in
        PokemonTeamMember(pokemon: pokemon, position: position)
    }

    return EditTeamView(team: team)
        .modelContainer(
            for: [PokemonTeam.self, PokemonTeamMember.self],
            inMemory: true
        )
}
