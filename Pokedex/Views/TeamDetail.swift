//
//  TeamDetail.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 1/9/2569 BE.
//

import SwiftUI

struct TeamMember: Identifiable {
    let id = UUID()
    let name: String
    let types: [PokemonType]
}

enum PokemonType: String {
    case electric = "Electric"
    case fire = "Fire"
    case flying = "Flying"
    case water = "Water"
    case grass = "Grass"
    case poison = "Poison"
    case ghost = "Ghost"
    case dragon = "Dragon"
    case ground = "Ground"

    var color: Color {
        switch self {
        case .electric: .yellow
        case .fire: .orange
        case .flying: .blue
        case .water: .blue
        case .grass: .green
        case .poison: .purple
        case .ghost: .indigo
        case .dragon: .indigo
        case .ground: .brown
        }
    }

    var symbol: String {
        switch self {
        case .electric: "bolt.fill"
        case .fire: "flame.fill"
        case .flying: "wind"
        case .water: "drop.fill"
        case .grass: "leaf.fill"
        case .poison: "circle.hexagongrid.fill"
        case .ghost: "sparkles"
        case .dragon: "hurricane"
        case .ground: "mountain.2.fill"
        }
    }
}

struct TeamDetail: View {
    @Environment(\.dismiss) private var dismiss

    let teamName: String
    let pokeballAssetName: String
    let accentColor: Color
    let members: [TeamMember]
    var capacity = 6

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                teamHeader
                memberList
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 110)
        }
        .background {
            Color.white
                .ignoresSafeArea()
        }
        .navigationTitle(teamName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Back")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    // Editing will be connected when team persistence is added.
                }
                .fontWeight(.semibold)
                .foregroundStyle(.red)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                // Pokémon selection will be connected later.
            } label: {
                Label("Add Pokémon", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.red, in: Capsule())
                    .shadow(color: .red.opacity(0.22), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(.white.opacity(0.96))
        }
    }

    private var teamHeader: some View {
        VStack(spacing: 12) {
            Image(pokeballAssetName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 64, height: 64)
                .padding(14)
                .background(accentColor.opacity(0.14), in: Circle())

            VStack(spacing: 4) {
                Text(teamName)
                    .font(.title2.bold())

                Text("\(members.count) / \(capacity) Pokémon")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var memberList: some View {
        VStack(spacing: 0) {
            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                TeamMemberRow(member: member)

                if index < members.count - 1 {
                    Divider()
                }
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 7, y: 2)
    }
}

private struct TeamMemberRow: View {
    let member: TeamMember

    var body: some View {
        Button {
            // Pokémon details will be connected when the team has stored Pokémon.
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 88, height: 72)
                    .accessibilityLabel("Pokémon image placeholder")

                VStack(alignment: .leading, spacing: 8) {
                    Text(member.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 6) {
                        ForEach(member.types, id: \.self) { type in
                            TypeBadge(type: type)
                        }
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 88)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(member.name), \(member.types.map(\.rawValue).joined(separator: ", "))")
    }
}

private struct TypeBadge: View {
    let type: PokemonType

    var body: some View {
        Label(type.rawValue, systemImage: type.symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(type.color.opacity(0.14), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        TeamDetail(
            teamName: "Kanto Champions",
            pokeballAssetName: "teamPokeBall",
            accentColor: .red,
            members: [
                TeamMember(name: "Pikachu", types: [.electric]),
                TeamMember(name: "Charizard", types: [.fire, .flying]),
                TeamMember(name: "Blastoise", types: [.water])
            ]
        )
    }
}
