import Foundation

struct Pokemon:Codable, Identifiable {
    let id:Int
    let name:String
    let height:Int
    let weight:Int
    let types:[PokemonType]
    let abilities: [PokemonAbility]
    let stats: [PokemonStat]
    let sprites: PokemonSprites
    
}
// Type

struct PokemonType:Codable {
    let type: PokemonTypeInfo
}
struct PokemonTypeInfo:Codable {
    let name: String
}
// Ability
struct PokemonAbility: Codable {
    let ability: PokemonAbilityInfo
}

struct PokemonAbilityInfo: Codable {
    let name: String
}

//Stat
struct PokemonStat: Codable {
    let baseStat: Int
    let stat: PokemonStatInfo

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct PokemonStatInfo: Codable {
    let name: String
}

// Images
struct PokemonSprites: Codable {
    let other: PokemonOtherSprites
}

struct PokemonOtherSprites: Codable {
    
    let officialArtwork: PokemonOfficialArtwork
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }

}

struct PokemonOfficialArtwork: Codable {
    let frontDefault: String?
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
