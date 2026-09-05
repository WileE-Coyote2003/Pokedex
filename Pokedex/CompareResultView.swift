import SwiftUI

struct CompareResultView: View {
    let pokemonA: Pokemon
    let pokemonB: Pokemon

    private var winner: Pokemon {
        func total(_ p: Pokemon) -> Int {
            p.stats.hp + p.stats.attack + p.stats.defense + p.stats.speed
        }
        return total(pokemonA) >= total(pokemonB) ? pokemonA : pokemonB
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                headerRow
                statsCard
                winnerCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Comparison Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .top) {
            pokemonHeader(pokemonA)
            Text("VS")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.top, 32)
            pokemonHeader(pokemonB)
        }
    }

    private func pokemonHeader(_ item: Pokemon) -> some View {
        VStack(spacing: 8) {
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .failure: Image(systemName: "pawprint.fill").foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(width: 88, height: 88)
            .padding(6)
            .background(item.primaryType.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))

            Text(item.name)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 4) {
                ForEach(item.types, id: \.self) { type in
                    PokemonTypeLabel(type: type)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(spacing: 14) {
            CompareStatRow(label: "HP", valueA: pokemonA.stats.hp, valueB: pokemonB.stats.hp, color: .red)
            CompareStatRow(label: "Attack", valueA: pokemonA.stats.attack, valueB: pokemonB.stats.attack, color: .orange)
            CompareStatRow(label: "Defense", valueA: pokemonA.stats.defense, valueB: pokemonB.stats.defense, color: .blue)
            CompareStatRow(label: "Speed", valueA: pokemonA.stats.speed, valueB: pokemonB.stats.speed, color: .green)

            Divider()

            CompareMetricRow(label: "Height", valueA: String(format: "%.1f m", pokemonA.height), valueB: String(format: "%.1f m", pokemonB.height))
            CompareMetricRow(label: "Weight", valueA: String(format: "%.1f kg", pokemonA.weight), valueB: String(format: "%.1f kg", pokemonB.weight))
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Winner

    private var winnerCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .foregroundStyle(.orange)
            Text("Winner: \(winner.name)!")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
    }
}

// MARK: - Reusable stat rows

private struct CompareStatRow: View {
    let label: String
    let valueA: Int
    let valueB: Int
    let color: Color

    private func progress(_ value: Int) -> Double { min(Double(value) / 150.0, 1.0) }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(valueA)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { proxy in
                ZStack(alignment: .trailing) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: proxy.size.width * progress(valueA))
                }
            }
            .frame(height: 10)

            Text(label)
                .font(.caption.weight(.semibold))
                .frame(width: 56)
                .multilineTextAlignment(.center)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: proxy.size.width * progress(valueB))
                }
            }
            .frame(height: 10)

            Text("\(valueB)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, alignment: .leading)
        }
    }
}

private struct CompareMetricRow: View {
    let label: String
    let valueA: String
    let valueB: String

    var body: some View {
        HStack {
            Text(valueA).frame(maxWidth: .infinity, alignment: .leading)
            Text(label).font(.subheadline.weight(.semibold)).frame(width: 70)
            Text(valueB).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        CompareResultView(pokemonA: Pokemon.sampleData[0], pokemonB: Pokemon.sampleData[1])
    }
}
