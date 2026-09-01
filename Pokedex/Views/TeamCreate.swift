//
//  TeamCreate.swift
//  Pokedex
//
//  Created by Thwin Htoo Aung on 31/8/2569 BE.
//

import SwiftUI

struct TeamCreate: View {
    @Environment(\.dismiss) private var dismiss

    @State private var teamName = ""
    @State private var selectedPokeball: PokeballOption = .pokeBall

    private let characterLimit = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                teamIcon
                    .frame(maxWidth: .infinity)
                    .padding(.top, 26)
                    .padding(.bottom, 34)

                Text("Team Name")
                    .font(.headline)

                TextField("Enter team name...", text: $teamName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(.white)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(.secondary.opacity(0.25), lineWidth: 1)
                    }
                    .padding(.top, 10)
                    .onChange(of: teamName) { _, newValue in
                        if newValue.count > characterLimit {
                            teamName = String(newValue.prefix(characterLimit))
                        }
                    }

                Text("\(teamName.count) / \(characterLimit)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 7)

                Text("Choose a Poké Ball")
                    .font(.headline)
                    .padding(.top, 20)

                HStack(spacing: 0) {
                    ForEach(PokeballOption.allCases) { pokeball in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedPokeball = pokeball
                            }
                        } label: {
                            PokeballOptionView(
                                pokeball: pokeball,
                                isSelected: selectedPokeball == pokeball,
                                size: 46
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(pokeball.name)
                        .accessibilityValue(
                            selectedPokeball == pokeball ? "Selected" : "Not selected"
                        )
                    }
                }
                .padding(.top, 14)

                Button {
                    // Save the new team when team storage is added.
                    dismiss()
                } label: {
                    Text("Create Team")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.red, in: Capsule())
                        .shadow(color: .red.opacity(0.22), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(trimmedTeamName.isEmpty)
                .opacity(trimmedTeamName.isEmpty ? 0.45 : 1)
                .padding(.top, 92)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Create New Team")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
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
        }
    }

    private var trimmedTeamName: String {
        teamName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var teamIcon: some View {
        PokeballSprite(pokeball: selectedPokeball)
            .frame(width: 76, height: 76)
            .padding(18)
            .background(.blue.opacity(0.1), in: Circle())
            .overlay {
                Circle()
                    .stroke(.blue.opacity(0.35), lineWidth: 1.5)
            }
    }
}

private enum PokeballOption: String, CaseIterable, Identifiable {
    case pokeBall
    case premierBall
    case greatBall
    case ultraBall
    case masterBall
    case safariBall

    var id: Self { self }

    var name: String {
        switch self {
        case .pokeBall: "Poké Ball"
        case .premierBall: "Premier Ball"
        case .greatBall: "Great Ball"
        case .ultraBall: "Ultra Ball"
        case .masterBall: "Master Ball"
        case .safariBall: "Safari Ball"
        }
    }

    var assetName: String {
        switch self {
        case .pokeBall: "teamPokeBall"
        case .premierBall: "teamPremierBall"
        case .greatBall: "teamGreatBall"
        case .ultraBall: "teamUltraBall"
        case .masterBall: "teamMasterBall"
        case .safariBall: "teamSafariBall"
        }
    }
}

private struct PokeballOptionView: View {
    let pokeball: PokeballOption
    let isSelected: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            PokeballSprite(pokeball: pokeball)
                .padding(3)

            if isSelected {
                Circle()
                    .stroke(.blue, lineWidth: 2.5)

                Circle()
                    .fill(.blue)
                    .frame(width: 18, height: 18)
                    .overlay {
                Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: size * 0.34, y: size * 0.34)
            }
        }
        .frame(width: size, height: size)
        .padding(5)
        .contentShape(Circle())
    }
}

private struct PokeballSprite: View {
    let pokeball: PokeballOption

    var body: some View {
        Image(pokeball.assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
    }
}
