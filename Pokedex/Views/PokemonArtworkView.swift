import SwiftUI

struct PokemonArtworkView: View {
    let pokemon: Pokemon

    @State private var retryAttempt = 0

    private let maximumRetryAttempts = 2

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
                    .task {
                        await retryAfterDelay()
                    }
            default:
                ProgressView()
            }
        }
        .id(ImageRequestID(url: pokemon.imageURL, retryAttempt: retryAttempt))
        .onChange(of: pokemon.imageURL) {
            retryAttempt = 0
        }
        .accessibilityLabel("\(pokemon.name) official artwork")
    }

    @MainActor
    private func retryAfterDelay() async {
        guard retryAttempt < maximumRetryAttempts else { return }

        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            return
        }

        retryAttempt += 1
    }
}

private struct ImageRequestID: Hashable {
    let url: URL?
    let retryAttempt: Int
}
