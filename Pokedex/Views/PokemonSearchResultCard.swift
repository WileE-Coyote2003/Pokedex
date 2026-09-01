import SwiftUI

struct PokemonSearchResultCard: View {

    let pokemon: Pokemon

    var body: some View {
        HStack(spacing: 12) {

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
                        .padding(10)
                        .foregroundStyle(.secondary)

                default:
                    ProgressView()
                }
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 5) {

                Text(pokemon.name)
                    .font(.headline)

                HStack(spacing: 5) {
                    Text(pokemon.typeIcon)

                    Text(pokemon.primaryType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(pokemon.formattedNumber)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 80)
        .background(Color(.secondarySystemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }
}