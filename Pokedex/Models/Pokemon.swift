import Foundation

struct PokemonStats: Hashable {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
}

struct Pokemon: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let types: [String]
    let height: Double
    let weight: Double
    let stats: PokemonStats
    let abilities: [String]
    private let artworkURL: URL?

    init(
        id: Int,
        name: String,
        types: [String],
        height: Double,
        weight: Double,
        stats: PokemonStats,
        abilities: [String],
        artworkURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.types = types
        self.height = height
        self.weight = weight
        self.stats = stats
        self.abilities = abilities
        self.artworkURL = artworkURL
    }

    var primaryType: String {
        types.first ?? "Normal"
    }

    var formattedNumber: String {
        String(format: "#%03d", id)
    }

    var imageURL: URL? {
        artworkURL ?? URL(
            string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        )
    }

    init(from decoder: Decoder) throws {
        let response = try APIResponse(from: decoder)

        id = response.id
        name = response.name.capitalized
        types = response.types.map { $0.type.name.capitalized }
        height = Double(response.height) / 10
        weight = Double(response.weight) / 10
        abilities = response.abilities.map {
            $0.ability.name.replacingOccurrences(of: "-", with: " ").capitalized
        }
        stats = PokemonStats(
            hp: response.stat(named: "hp"),
            attack: response.stat(named: "attack"),
            defense: response.stat(named: "defense"),
            speed: response.stat(named: "speed")
        )
        artworkURL = response.sprites.other.officialArtwork.frontDefault.flatMap(URL.init(string:))
    }
}

private struct APIResponse: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [APITypeSlot]
    let abilities: [APIAbilitySlot]
    let stats: [APIStatSlot]
    let sprites: APISprites

    func stat(named name: String) -> Int {
        stats.first { $0.stat.name == name }?.baseStat ?? 0
    }
}

private struct APITypeSlot: Decodable {
    let type: APIName
}

private struct APIAbilitySlot: Decodable {
    let ability: APIName
}

private struct APIStatSlot: Decodable {
    let baseStat: Int
    let stat: APIName

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

private struct APIName: Decodable {
    let name: String
}

private struct APISprites: Decodable {
    let other: APIOtherSprites
}

private struct APIOtherSprites: Decodable {
    let officialArtwork: APIOfficialArtwork

    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

private struct APIOfficialArtwork: Decodable {
    let frontDefault: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
