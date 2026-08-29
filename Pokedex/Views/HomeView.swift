//
//  HomeView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            Text("Home content will go here")
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Menu", systemImage: "line.3.horizontal") {
                    // Menu action will be added here.
                }
                .labelStyle(.iconOnly)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Favorites", systemImage: "heart") {
                    // Favorites action will be added here.
                }
                .labelStyle(.iconOnly)
            }
        }
    }
}
