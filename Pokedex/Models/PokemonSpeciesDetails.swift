import Foundation

struct PokemonSpeciesDetails: Equatable {
    let name: String
    let genus: String
    let description: String
    let generation: String
    let region: String
    let habitat: String?
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool
}
