//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PokemonTeam.self, PokemonTeamMember.self])
    }
}
