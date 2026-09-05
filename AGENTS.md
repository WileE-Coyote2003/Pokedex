# Pokédex Project Guide

This file provides project context for developers and AI coding agents. Read it before changing the app.

## Project Overview

Pokédex is a SwiftUI iOS app for browsing Pokémon, viewing details, searching, comparing Pokémon, and building teams. The project currently uses local sample Pokémon for the UI while PokeAPI networking is integrated incrementally.

The app has four tabs, each with its own `NavigationStack`:

- Home: popular Pokémon grid and detail navigation.
- Search: searchable list using `PokemonSearchResultCard`.
- Team: team overview, creation, and detail screens.
- Compare: Pokémon comparison flow.

## Project Structure

```text
Pokedex/
├── Models/
│   ├── Pokemon.swift             # Canonical app model and PokeAPI decoding
│   └── Pokemon+TypeIcon.swift    # Permanent primary-type icon mapping
├── Services/
│   └── PokemonService.swift      # PokeAPI networking
├── Views/
│   ├── Models.swift              # Local samplePokemon fixtures only
│   ├── HomeView.swift
│   ├── SearchView.swift
│   ├── PokemonCardView.swift
│   ├── PokemonSearchResultCard.swift
│   ├── PokemonDetailView.swift
│   ├── TeamView.swift
│   ├── TeamCard.swift
│   ├── TeamCreate.swift
│   ├── TeamDetail.swift
│   ├── CompareView.swift
│   └── CompareResultView.swift
├── ContentView.swift             # Root tab navigation
└── PokedexApp.swift              # Application entry point
```

The Xcode project uses a file-system-synchronized root group. New source files placed under `Pokedex/` are discovered automatically; avoid manually adding duplicate file references to `project.pbxproj`.

## Model Ownership

There must be exactly one `Pokemon` declaration: `Pokedex/Models/Pokemon.swift`.

The canonical `Pokemon` model contains UI-friendly values:

- `types` and `abilities` are string arrays.
- `height` is stored in metres.
- `weight` is stored in kilograms.
- `stats` is a `PokemonStats` value containing HP, attack, defense, and speed.
- `primaryType` is the first returned type, with `Normal` as a fallback.
- `imageURL` prefers official PokeAPI artwork and falls back to the public sprite repository.

Do not introduce another `Pokemon`, `PokemonType`, or API-specific model with a conflicting global name. Raw PokeAPI response helpers should remain private implementation details in `Pokemon.swift`, or receive an explicit `API` prefix.

## Sample Data

`Pokedex/Views/Models.swift` intentionally remains in the project for `samplePokemon`. It is fixture data used by Home, Search, Team, previews, and unfinished features until those screens are connected to live data.

Keep sample fixtures separate from the canonical model. Do not move production model declarations back into this file. When a screen is migrated to networking, preserve `samplePokemon` for SwiftUI previews unless the team agrees to replace it with a dedicated preview-data structure.

## Primary-Type Icons

`Pokedex/Models/Pokemon+TypeIcon.swift` permanently defines `Pokemon.typeIcon`. The app represents a Pokémon with the icon for its primary type only, even when it has multiple types.

Use `pokemon.typeIcon`; do not recreate type-to-icon switches inside views. Team creation and team-detail Pokémon cards use this icon. The empty capacity slots on the team overview card must remain empty placeholders and must not display type icons.

Poké Ball assets represent a team's identity and are separate from Pokémon primary-type icons.

## Networking and PokeAPI

`PokemonService.fetchPokemon(name:)` requests:

```text
GET https://pokeapi.co/api/v2/pokemon/{lowercased-name}
```

It validates an HTTP 200 response and decodes the result into the canonical `Pokemon` model. PokeAPI returns height in decimetres and weight in hectograms; `Pokemon.init(from:)` converts both values to metres and kilograms.

Networking rules:

- Put HTTP request logic in `Services`, not SwiftUI views.
- Decode external response shapes at the model/service boundary.
- Present UI-friendly `Pokemon` values to views.
- Preserve `async throws` error propagation so callers can show loading, empty, and error states.
- Avoid force-unwrapping URLs or decoded values.
- Do not assume that every artwork URL or stat is present.

The current Home, Search, and Team screens still use `samplePokemon`. Do not claim they are live-network-backed until their loading and error states are implemented.

## Team UI Rules

- Team views use `[Pokemon]`, not a separate duplicate team-member Pokémon model.
- A team has a capacity of six Pokémon.
- Team overview capacity slots remain visually empty placeholders.
- Create Team may select at most six sample Pokémon.
- Team-detail cards show only the Pokémon's primary type and `typeIcon`.
- Poké Ball selection is team branding and should not be replaced by a Pokémon type icon.
- Team persistence and editing are not implemented yet; do not invent storage behavior without an explicit task.

## SwiftUI Conventions

- Keep views small and extract reusable cards or rows when a view becomes difficult to scan.
- Pass `Pokemon` values between screens instead of copying their fields into new structs.
- Use `NavigationLink` for detail navigation and keep each tab's existing `NavigationStack` boundary.
- Include accessibility labels for icon-only controls and meaningful visual icons.
- Keep previews backed by `samplePokemon` so they work without network access.
- Preserve light/dark adaptive system colors unless a design explicitly requires a fixed color.

## Current Limitations

- Most screens still use local sample data.
- Team creation, editing, and membership are not persisted.
- Favorites are local view state and are not persisted.
- Compare functionality is still evolving.
- The project currently has no automated test target.

## Build Verification

After model, networking, or SwiftUI changes, run:

```sh
xcodebuild \
  -project Pokedex.xcodeproj \
  -scheme Pokedex \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/PokedexDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  ARCHS=arm64 \
  build
```

The expected result is `BUILD SUCCEEDED`. Also run `git diff --check` before handing off changes.

## Change Checklist

Before completing work:

1. Confirm no duplicate `Pokemon` or type declarations were introduced.
2. Keep sample fixtures and production model code in their documented locations.
3. Reuse the permanent `typeIcon` mapping for primary-type icons.
4. Keep team overview capacity slots empty.
5. Verify previews and navigation call sites still compile.
6. Build the complete app and check the diff for formatting errors.
