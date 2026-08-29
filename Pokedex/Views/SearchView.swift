//
//  SearchView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    var body: some View {
        VStack {
            Text("Search results will go here")
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: "Search Pokémon"
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                    // Filter action will be added here.
                }
                .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
