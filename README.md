# Pokédex

Pokédex is a native iOS app built with SwiftUI for discovering Pokémon, viewing detailed information, saving favorites, comparing stats, and creating custom teams. Pokémon data and official artwork are loaded from [PokéAPI](https://pokeapi.co/), while favorites and teams are stored locally with SwiftData.

## Features

- Browse a curated set of featured Pokémon on the home screen.
- Search by Pokémon name or Pokédex number.
- Filter Pokémon by type and load additional results as you scroll.
- View types, abilities, dimensions, base stats, species information, region, generation, and habitat.
- Save favorite Pokémon for quick access.
- Create multiple teams with custom names and Poké Ball branding.
- Add up to six Pokémon to each team.
- Rename teams, remove members, and drag to reorder the lineup.
- Compare two Pokémon side by side across their stats and physical information.
- Handle loading, empty, offline, and API error states throughout the app.

## Screens

The app is organized into four main tabs:

1. **Home** — featured Pokémon and access to saved favorites.
2. **Search** — live PokéAPI browsing, searching, type filtering, and pagination.
3. **Team** — locally persisted team creation and management.
4. **Compare** — selection and side-by-side comparison of two Pokémon.

## Technology

- Swift 5
- SwiftUI
- Swift Concurrency (`async`/`await` and task groups)
- SwiftData
- URLSession
- PokéAPI
- Xcode project with no third-party package dependencies

## Requirements

- macOS with Xcode installed
- An iOS Simulator or physical iOS device
- Internet access for Pokémon data and artwork
- An Xcode/iOS SDK version compatible with the project's current iOS 26.4 deployment target

## Getting Started

1. Clone the repository:

   ```sh
   git clone <repository-url>
   cd Pokedex
   ```

2. Open the Xcode project:

   ```sh
   open Pokedex.xcodeproj
   ```

3. Select the **Pokedex** scheme and an available iOS Simulator.

4. Build and run with **Command-R**.

No API key or additional dependency installation is required.

## Project Structure

```text
Pokedex/
├── Models/                  # Pokémon, species, favorites, and team models
├── Services/                # PokéAPI networking and response handling
├── Views/                   # SwiftUI screens and reusable components
├── Assets.xcassets/         # App icon, colors, and Poké Ball artwork
├── ContentView.swift        # Root tab navigation
└── PokedexApp.swift         # App entry point and SwiftData container
```

## Data and Persistence

`PokemonService` communicates with the public PokéAPI using URLSession. It supports fetching individual Pokémon, paginated lists, type-filtered results, and species metadata. Responses are converted into UI-friendly `Pokemon` values, including metric height and weight.

Favorites, teams, team branding, and team membership are persisted on-device with SwiftData. Preview fixtures remain local so SwiftUI previews can run without a network connection.

## Build from the Command Line

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


## Credits

Pokémon data and artwork are provided by [PokéAPI](https://pokeapi.co/). Pokémon and Pokémon character names are trademarks of Nintendo, Game Freak, and The Pokémon Company. This project is an unofficial educational application and is not affiliated with or endorsed by those companies.
