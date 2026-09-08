//
//  PokemonTeam.swift
//  Pokedex
//

import Foundation
import SwiftData

@Model
final class PokemonTeam {
    @Attribute(.unique) var id: UUID
    var name: String
    var pokeballAssetName: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \PokemonTeamMember.team)
    var members: [PokemonTeamMember] = []

    init(
        id: UUID = UUID(),
        name: String,
        pokeballAssetName: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.pokeballAssetName = pokeballAssetName
        self.createdAt = createdAt
    }

    var sortedMembers: [PokemonTeamMember] {
        members.sorted { $0.position < $1.position }
    }
}

@Model
final class PokemonTeamMember {
    @Attribute(.unique) var id: UUID
    var pokemonID: Int
    var name: String
    var types: [String]
    var height: Double
    var weight: Double
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var abilities: [String]
    var artworkURLString: String?
    var position: Int
    var team: PokemonTeam?

    init(pokemon: Pokemon, position: Int, team: PokemonTeam? = nil) {
        id = UUID()
        pokemonID = pokemon.id
        name = pokemon.name
        types = pokemon.types
        height = pokemon.height
        weight = pokemon.weight
        hp = pokemon.stats.hp
        attack = pokemon.stats.attack
        defense = pokemon.stats.defense
        speed = pokemon.stats.speed
        abilities = pokemon.abilities
        artworkURLString = pokemon.imageURL?.absoluteString
        self.position = position
        self.team = team
    }

    var pokemon: Pokemon {
        Pokemon(
            id: pokemonID,
            name: name,
            types: types,
            height: height,
            weight: weight,
            stats: PokemonStats(
                hp: hp,
                attack: attack,
                defense: defense,
                speed: speed
            ),
            abilities: abilities,
            artworkURL: artworkURLString.flatMap(URL.init(string:))
        )
    }
}
