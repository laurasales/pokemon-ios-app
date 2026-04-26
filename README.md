# WallaMarvel — iOS Tech Challenge

A Pokédex app built as an iOS Engineer technical challenge.

The starter project provided a Marvel API + MVP + UIKit skeleton with intentional errors. Rather than patch it incrementally, I replaced the entire implementation to present a coherent architectural vision from scratch. The Marvel API also has known reliability problems, so I switched to PokéAPI, which is free, requires no key, and has a public OpenAPI spec I could use to demonstrate modern Apple tooling.

For a detailed breakdown of every non-obvious choice, see [`docs/decisions.md`](docs/decisions.md).

---

## What I implemented

All mandatory requirements are covered, and so are all the nice-to-haves.

**Mandatory**
- **Pokémon detail screen** — sprite, type badges, base stats with progress bars, abilities, and a favourite toggle. Opened by tapping any row; data fetched from `GET /pokemon/{id}`.
- **Pagination** — infinite scroll, 20 Pokémon per page. The next page is prefetched when the user is within 5 items of the end of the current list.

**Nice to have (all implemented)**
- **Search** — accepts a full Pokémon name or Pokédex number (exact-match, see [known limitations](#known-limitations)).
- **Swift Concurrency** — `async/await` throughout, `@MainActor` on all view models, structured concurrency via `.task {}`.
- **SwiftUI** — entire UI is SwiftUI; no storyboards, no UIKit views.
- **Accessibility** — accessibility labels and traits on all interactive elements; reduce-motion support; snapshot tests of the accessibility tree using `AccessibilitySnapshot`.

**Extras I added to demonstrate the stack**
- **Favourites** — persisted across launches via Realm; toggleable from the list and detail screens.
- **Type filter** — horizontal badge strip that filters the list by Pokémon type (`GET /type/{name}`).
- **Pokémon cry playback** — plays the cry on the detail screen via `AVPlayer`.
- **SwiftLint + SwiftFormat** — enforced as Xcode build phases.

---

## Architecture

Clean Architecture with MVVM, all UI in SwiftUI.

```
Network / Data  →  Repository  →  Use Cases  →  ViewModel  →  SwiftUI View
```

- **Network layer** — `PokemonNetworkServiceProtocol` with two concrete implementations: `OpenAPIPokemonNetworkService` (active, uses Apple's Swift OpenAPI Generator against a vendored PokéAPI spec) and `PokemonAPINetworkService` (a third-party wrapper kept as a reference). Swapping is a one-line change in `DependencyContainer`.
- **Data layer** — `PokemonRepository` and `FavoritesRepository` (Realm). Repositories map DTOs to domain models so the domain never sees a networking or persistence type.
- **Domain layer** — pure Swift value types (`Pokemon`, `PokemonDetail`) and one use case per action, each behind its own protocol.
- **Presentation layer** — `PokemonListViewModel` and `PokemonDetailViewModel` are `@MainActor ObservableObject`s constructed by `DependencyContainer` and injected via the SwiftUI environment.
- **DI** — `DependencyContainer` is created once in `SceneDelegate` and passed into the environment. `PokemonDetailContainerView` resolves its view model from the environment, so `NavigationStack` only needs to pass a plain `Int` (Pokédex ID) as the navigation value — the list knows nothing about the detail's dependencies.

See [`docs/architecture.md`](docs/architecture.md) for the full layer breakdown with diagrams.

---

## Building and running

Requires Xcode 16+ and an iPhone 16 simulator (OS 18.5).

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

---

## Testing

- **Unit tests** — `PokemonListViewModelSpec` and `PokemonDetailViewModelSpec` use Quick + Nimble. Every use case and repository is behind a protocol; mocks cover success, failure, and edge cases. No third-party mocking framework — each mock is a simple struct.
- **Accessibility snapshot tests** — `AccessibilitySnapshotTests` uses `AccessibilitySnapshot` + `SnapshotTesting` to assert the accessibility tree of all shared components and detail sections. This catches regressions in labels, traits, and `accessibilityHidden` on every CI run without requiring a manual audit.
- Test files are excluded from SwiftLint to avoid false positives on `force_try` and `@testable import`.

---

## Tooling

| Tool | Purpose |
|---|---|
| SwiftLint | Style enforcement; `force_unwrapping` opt-in rule guards against `!` regressions |
| SwiftFormat | Consistent formatting; `--header ignore` preserves file headers |

Both linters run as Xcode Run Script build phases (not SPM plugins) to avoid minimum deployment target conflicts with the iOS target.

---

## Dependencies

| Package | Source | Use |
|---|---|---|
| swift-openapi-generator | Apple (exact version) | Generates type-safe network client from `openapi.yaml` |
| swift-openapi-runtime | Apple (exact version) | Runtime for the generated client |
| swift-openapi-urlsession | Apple (exact version) | URLSession transport for the OpenAPI client |
| PokemonAPI | kinkofer (exact version) | Alternative PokéAPI Swift wrapper (kept as a reference implementation) |
| realm-swift | Realm (exact version) | Favourites persistence |
| Kingfisher | onevcat (up to next major) | Remote image loading for sprites |
| Quick | Quick/Quick (branch: main) | BDD test framework |
| Nimble | Quick/Nimble (branch: main) | Matcher library for Quick |
| AccessibilitySnapshot | CashApp (exact version) | Accessibility tree snapshot tests |

Quick and Nimble are pinned to `branch: main` because no tagged release supported Swift 6 / Xcode 16 at the time of writing. This is a known trade-off I accepted for a demo context; a production project should wait for a tagged release.

---

## Known limitations

- **Search is exact-match only.** PokéAPI has no partial-name search endpoint. The search bar calls `GET /pokemon/{name|id}`, which returns one result for an exact match or a 404 for anything else. A production alternative would be to pre-fetch the full names list once and filter client-side as the user types — I kept a note on this trade-off in [`docs/decisions.md`](docs/decisions.md).

- **List sprite URLs are constructed, not fetched.** The paginated list endpoint returns only `name` and `url` (no sprites). I extract the Pokédex ID from the resource URL and derive the sprite URL from the known GitHub sprites CDN path. This avoids firing 20+ concurrent requests per page load, but introduces a CDN dependency. The detail screen uses `sprites.front_default` directly from the full Pokémon object.

- **Pokémon cry audio comes from Pokémon Showdown.** PokéAPI provides cries as `.ogg` files, which AVFoundation cannot decode natively on iOS. Rather than add an untagged OGG decoder dependency, I stream MP3 cries from `play.pokemonshowdown.com`. This is an unofficial CDN — acceptable for a demo, not for production.
