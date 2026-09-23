import Foundation
import SwiftData

@Model
final class FavoritePokemon {
    @Attribute(.unique) var pokemonID: Int
    var name: String
    var types: [String]
    var height: Double
    var weight: Double
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var abilities: [String]
    var speciesName: String?
    var artworkURLString: String?
    var savedAt: Date

    init(pokemon: Pokemon, savedAt: Date = .now) {
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
        speciesName = pokemon.speciesName
        artworkURLString = pokemon.imageURL?.absoluteString
        self.savedAt = savedAt
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
            speciesName: speciesName,
            artworkURL: artworkURLString.flatMap(URL.init(string:))
        )
    }
}
