# WallaMarvel — iOS Tech Challenge

A Pokédex app built as a iOS Engineer technical challenge. The starter project used Marvel's API with an MVP + UIKit skeleton; this submission replaces it entirely with PokéAPI, SwiftUI, and Clean Architecture + MVVM.

## Features
- Pokémon list with infinite scroll pagination (20 per page, next page fetched when 5 items from the end)
- Pokémon detail screen with sprite, types, stats, and abilities
- Search by name or Pokédex number
- Type filter bar (tap any type badge to filter the list)
- Favourites — persist across launches via Realm; toggle from list and detail
- Pokémon cry playback on the detail screen
- Accessibility support throughout (labels, traits, reduce-motion, snapshot tests)
- Full Swift Concurrency (async/await, `@MainActor`, structured concurrency)

## Architecture

Clean Architecture with MVVM, all UI in SwiftUI.

```
Network / Data  →  Repository  →  Use Cases  →  ViewModel  →  SwiftUI View
```

- **Network layer** — `PokemonNetworkServiceProtocol` with two concrete implementations: `OpenAPIPokemonNetworkService` (active, uses Apple's Swift OpenAPI Generator against a vendored PokéAPI spec) and `PokemonAPINetworkService` (a third-party wrapper kept as an alternative). Swapping is a one-line change in `DependencyContainer`.
- **Data layer** — `PokemonRepository` and `FavoritesRepository` (Realm). Repositories map DTOs to domain models.
- **Domain layer** — pure Swift structs (`Pokemon`, `PokemonDetail`) and one use case per action, each behind a protocol.
- **Presentation layer** — `PokemonListViewModel` and `PokemonDetailViewModel` are `@MainActor ObservableObject`s injected by `DependencyContainer`.
- **DI** — `DependencyContainer` is an `ObservableObject` created in `SceneDelegate` and passed into the SwiftUI environment. `PokemonDetailContainerView` resolves its view model from the environment, keeping detail navigation decoupled from the list.

See [`docs/architecture.md`](docs/architecture.md) for the full layer breakdown and [`docs/decisions.md`](docs/decisions.md) for rationale behind key choices.

## Building and Running

Requires Xcode 16+ and an iPhone 16 simulator.

```bash
# Build
xcodebuild -project WallaMarvel.xcodeproj -scheme WallaMarvel -configuration Debug build

# Run all tests
xcodebuild -project WallaMarvel.xcodeproj -scheme WallaMarvel \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test

# Run a single test class
xcodebuild -project WallaMarvel.xcodeproj -scheme WallaMarvel \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
  -only-testing:WallaMarvelTests/PokemonListViewModelSpec test
```

## Testing

- **Unit tests** — `PokemonListViewModelSpec` and `PokemonDetailViewModelSpec` use Quick + Nimble. Every use case and repository is behind a protocol; mocks cover success, failure, and edge cases.
- **Accessibility snapshot tests** — `AccessibilitySnapshotTests` uses `AccessibilitySnapshot` + `SnapshotTesting` to assert the accessibility tree of all shared and detail components.
- Test files are excluded from SwiftLint to avoid false positives on `force_try` and `@testable` patterns.

## Tooling

| Tool | Purpose |
|---|---|
| SwiftLint | Enforces style; `force_unwrapping` opt-in rule guards against `!` regressions |
| SwiftFormat | Consistent formatting; `--header ignore` preserves file headers |
| GitHub Actions | CI runs build + test on every push/PR to `main` and `develop` |

Both linters run as Xcode Run Script build phases (not SPM framework dependencies) to avoid minimum deployment target conflicts.

## Dependencies

| Package | Source | Use |
|---|---|---|
| swift-openapi-generator | Apple (exact version) | Generates type-safe network client from `openapi.yaml` |
| swift-openapi-runtime | Apple (exact version) | Runtime for generated client |
| swift-openapi-urlsession | Apple (exact version) | URLSession transport for OpenAPI client |
| PokemonAPI | kinkofer (exact version) | Alternative PokéAPI Swift wrapper (kept for comparison) |
| realm-swift | Realm (exact version) | Favourites persistence |
| Kingfisher | onevcat (up to next major) | Remote image loading for sprites |
| Quick | Quick/Quick (branch: main) | BDD test framework |
| Nimble | Quick/Nimble (branch: main) | Matcher library for Quick |
| AccessibilitySnapshot | CashApp (exact version) | Accessibility tree snapshot tests |

Quick and Nimble are pinned to `branch: main` because no tagged release supports Swift 6 / Xcode 16 at the time of writing. This is a known trade-off accepted for a tech challenge; a production project should wait for a tagged release or fork.

## Known Limitations

- **Search is exact-match only.** PokéAPI has no partial-name search endpoint; the search bar accepts a full name or Pokédex number and calls `GET /pokemon/{id}`. A production app could pre-fetch the names list and filter client-side, or use a dedicated search backend.
- **List sprite URLs are constructed from the Pokédex ID.** The paginated list endpoint returns only `name` and `url` (no sprites). The sprite URL is derived by extracting the ID from the resource URL and constructing the official GitHub sprites CDN path. The detail screen uses `sprites.front_default` directly from the full Pokémon object. A production app with a richer backend or local cache would avoid this CDN dependency.
- **Pokémon cry audio** is streamed from the Pokémon Showdown CDN (`play.pokemonshowdown.com`), not PokéAPI, because PokéAPI's OGG cry files are not natively decodable by AVFoundation on iOS.
