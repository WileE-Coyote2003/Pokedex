//
//  TeamView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI
import SwiftData

struct TeamView: View {
    @Query(sort: \PokemonTeam.createdAt, order: .reverse)
    private var teams: [PokemonTeam]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Teams")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Build and manage your Pokémon teams")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    NavigationLink {
                        TeamCreate()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(.red, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: .red.opacity(0.25), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Create a new team")
                }

                if teams.isEmpty {
                    emptyState
                        .padding(.top, 64)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(teams) { team in
                            let members = team.sortedMembers.map(\.pokemon)

                            TeamCard(
                                name: team.name,
                                members: members,
                                pokeballAssetName: team.pokeballAssetName,
                                borderColor: accentColor(for: team.pokeballAssetName),
                                destination: TeamDetail(
                                    team: team,
                                    accentColor: accentColor(for: team.pokeballAssetName)
                                )
                            )
                            .accessibilityIdentifier("teamCard-\(team.id.uuidString)")
                        }
                    }
                    .padding(.top, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background {
            Color.white
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Teams Yet",
            systemImage: "person.3",
            description: Text("Tap the plus button to create your first team.")
        )
    }

    private func accentColor(for assetName: String) -> Color {
        switch assetName {
        case "teamGreatBall": .blue
        case "teamUltraBall": .yellow
        case "teamMasterBall": .purple
        case "teamSafariBall": .green
        default: .red
        }
    }
}

#Preview {
    NavigationStack {
        TeamView()
    }
    .modelContainer(
        for: [PokemonTeam.self, PokemonTeamMember.self],
        inMemory: true
    )
}
