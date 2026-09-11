import Foundation
import SwiftData

enum PokemonTeamMembershipError: LocalizedError {
    case alreadyMember
    case teamFull

    var errorDescription: String? {
        switch self {
        case .alreadyMember:
            "This Pokémon is already on that team."
        case .teamFull:
            "That team already has six Pokémon."
        }
    }
}

enum PokemonTeamMembership {
    static func contains(_ pokemon: Pokemon, in team: PokemonTeam) -> Bool {
        team.members.contains { $0.pokemonID == pokemon.id }
    }

    static func add(
        _ pokemon: Pokemon,
        to team: PokemonTeam,
        in modelContext: ModelContext
    ) throws {
        guard !contains(pokemon, in: team) else {
            throw PokemonTeamMembershipError.alreadyMember
        }

        guard team.members.count < PokemonTeam.capacity else {
            throw PokemonTeamMembershipError.teamFull
        }

        let nextPosition = (team.members.map(\.position).max() ?? -1) + 1
        let member = PokemonTeamMember(
            pokemon: pokemon,
            position: nextPosition
        )

        modelContext.insert(member)
        team.members.append(member)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
