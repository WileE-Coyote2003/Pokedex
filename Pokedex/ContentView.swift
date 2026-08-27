//
//  ContentView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            NavigationStack{
                HomeView()
            }
            .tabItem {
                Label("Home",systemImage: "house")
            }
            NavigationStack{
                SearchView()
            }
            .tabItem {
                Label("Search",systemImage: "magnifyingglass")
            }
            NavigationStack{
                TeamView()
            }
            .tabItem {
                Label("Team",systemImage: "heart")
            }
            NavigationStack{
                CompareView()
            }
            .tabItem {
                Label("Compare",systemImage: "arrow.left.arrow.right")
            }
        }
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
    }
}

#Preview {
    ContentView()
}
