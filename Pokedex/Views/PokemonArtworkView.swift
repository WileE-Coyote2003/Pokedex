import SwiftUI

struct PokemonArtworkView: View {
    let pokemon: Pokemon

    var body: some View {
        AsyncImage(url: pokemon.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .foregroundStyle(.secondary)
            default:
                ProgressView()
            }
        }
        .accessibilityLabel("\(pokemon.name) official artwork")
    }
}
