//
//  TeamView.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 27/8/2569 BE.
//

import SwiftUI

struct TeamView: View {
    var body: some View {
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
                        .frame(width: 50, height: 50)
                        .background(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create a new team")
            }
            .padding(.horizontal)
            .padding(.top, 16)
            Divider()
                .padding(.top, 18)

            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "person.2")
                    .font(.system(size: 54, weight: .regular))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text("No team yet!")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Create your first Pokémon team!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .navigationBarHidden(true)
    }
}
