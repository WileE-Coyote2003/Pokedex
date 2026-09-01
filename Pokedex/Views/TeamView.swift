//
//  TeamView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct TeamView: View {
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

                TeamCard(
                    name: "Kanto Champions",
                    pokemonCount: kantoMembers.count,
                    pokeballAssetName: "teamPokeBall",
                    borderColor: .red,
                    destination: TeamDetail(
                        teamName: "Kanto Champions",
                        pokeballAssetName: "teamPokeBall",
                        accentColor: .red,
                        members: kantoMembers
                    )
                )
                .padding(.top, 24)
                .accessibilityIdentifier("kantoChampionsTeamCard")

                TeamCard(
                    name: "Sinnoh Legends",
                    pokemonCount: sinnohMembers.count,
                    pokeballAssetName: "teamGreatBall",
                    borderColor: .blue,
                    destination: TeamDetail(
                        teamName: "Sinnoh Legends",
                        pokeballAssetName: "teamGreatBall",
                        accentColor: .blue,
                        members: sinnohMembers
                    )
                )
                .padding(.top, 16)
                .accessibilityIdentifier("sinnohLegendsTeamCard")
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

    private var kantoMembers: [TeamMember] {
        [
            TeamMember(name: "Pikachu", types: [.electric]),
            TeamMember(name: "Charizard", types: [.fire, .flying]),
            TeamMember(name: "Blastoise", types: [.water]),
            TeamMember(name: "Venusaur", types: [.grass, .poison]),
            TeamMember(name: "Gengar", types: [.ghost, .poison]),
            TeamMember(name: "Dragonite", types: [.dragon, .flying])
        ]
    }

    private var sinnohMembers: [TeamMember] {
        [
            TeamMember(name: "Torterra", types: [.grass, .ground]),
            TeamMember(name: "Garchomp", types: [.dragon, .ground])
        ]
    }
}

#Preview {
    NavigationStack {
        TeamView()
    }
}
