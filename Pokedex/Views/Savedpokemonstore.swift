import Foundation

/// Tracks which Pokémon the user has saved/favorited during this app session.
///
/// This is in-memory only — nothing is written to disk, there is no
/// networking, and the list resets every time the app relaunches.
/// It exists purely so the heart button on `PokemonDetailView` and the
/// list on `SavedPokemonView` can share the same local state.
@Observable
final class SavedPokemonStore {
    private(set) var savedPokemon: [Pokemon]

    init(savedPokemon: [Pokemon] = []) {
        self.savedPokemon = savedPokemon
    }

    func isSaved(_ pokemon: Pokemon) -> Bool {
        savedPokemon.contains { $0.id == pokemon.id }
    }

    func toggle(_ pokemon: Pokemon) {
        if isSaved(pokemon) {
            remove(pokemon)
        } else {
            savedPokemon.append(pokemon)
        }
    }

    func remove(_ pokemon: Pokemon) {
        savedPokemon.removeAll { $0.id == pokemon.id }
    }
}