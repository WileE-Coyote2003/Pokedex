import SwiftUI

struct PokemonCardView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

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
                        .padding(30)
                        .foregroundStyle(.secondary)

                default:
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(pokemon.name)
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(pokemon.formattedNumber)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 5) {
                Text(pokemon.typeIcon)

                Text(pokemon.primaryType)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview {
    PokemonCardView(pokemon: samplePokemon[0])
        .padding()
}
