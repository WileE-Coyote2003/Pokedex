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
}
