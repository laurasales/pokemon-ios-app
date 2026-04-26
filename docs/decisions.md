# Decisions

Key architectural and tooling choices, with rationale.

---

## Replacing the starter project

The original skeleton used Marvel's API, MVP, and UIKit with known intentional errors. Rather than patch it incrementally, the entire implementation was replaced to demonstrate a coherent architectural vision and to avoid inheriting structural debt that would complicate discussion during the technical interview.

---

## SwiftUI over UIKit

SwiftUI was chosen for the entire UI. Reasons:

- Listed as a "nice to have" in the tech challenge requirements.
- Wallapop's production stack already includes SwiftUI alongside UIKit — demonstrating comfort with both is relevant.
- `NavigationStack`, `.searchable`, `.task`, and `.refreshable` remove significant boilerplate compared to their UIKit equivalents, leaving the code focused on product logic.

---

## MVVM over MVP

The original skeleton used MVP. MVVM was chosen instead because:

- `@Published` + `ObservableObject` is SwiftUI's native data-binding model; wiring a separate `Presenter` protocol through `@EnvironmentObject` would add indirection without benefit.
- Every use-case and repository boundary remains behind a protocol, so testability is not reduced — view models are tested in isolation via mock use cases.

---

## Swift OpenAPI Generator (active network implementation)

The paginated list, detail, search, and type endpoints are served by `OpenAPIPokemonNetworkService`, generated from a vendored PokéAPI OpenAPI 3.1 spec using Apple's `swift-openapi-generator`.

**Why this over hand-written networking:**
- Zero hand-written `Codable` structs or URL construction for covered endpoints.
- The compiler validates the request/response contract at build time; a spec update immediately surfaces breaking changes as compile errors.
- Demonstrates familiarity with modern Apple tooling (the generator was introduced at WWDC 2023).

**Why keep `PokemonAPINetworkService` as well:**
The third-party `PokemonAPI` wrapper was the first implementation. Keeping it alongside the OpenAPI version makes the protocol boundary tangible — swapping implementations is a one-line change in `DependencyContainer`. It also provides a fallback if the OpenAPI spec drifts from the live API.

---

## PokéAPI over Marvel API

PokéAPI was chosen as the data source because:

- The tech challenge note says "feel free to use another API" if Marvel has issues — and Marvel's API has reliability problems.
- PokéAPI is free, requires no API key, has a public OpenAPI spec, and has comprehensive endpoints (list, detail, types, search).

---

## Realm for favourites persistence

Realm was chosen over CoreData for the favourites store because:

- Wallapop's production stack uses both Realm and CoreData; demonstrating Realm is directly relevant.
- Realm's object model requires less boilerplate than CoreData's NSManagedObject for a simple persisted list.
- `FavoritesRepository` wraps Realm behind `FavoritesRepositoryProtocol`, so the persistence technology is swappable without touching the domain or presentation layers.

The `DependencyContainer` falls back to an in-memory Realm store if the on-disk store fails to initialise, preventing a launch crash at the cost of non-persistent favourites in that edge case.

---

## Quick + Nimble for unit tests

Wallapop's production stack uses Quick and Nimble. The view model tests mirror that style:

- `AsyncSpec` subclasses with `describe` / `context` / `it` blocks.
- `@MainActor` factory functions in spec scope isolate each example.
- Each mock use case is a simple struct that either returns a preconfigured value or throws a preconfigured error — no third-party mocking framework.

---

## Accessibility snapshot tests

`AccessibilitySnapshot` (CashApp) was added to snapshot-test the accessibility tree of shared components (`PokemonRowView`, `PokemonTypeBadgeView`, detail section views). This catches regressions in `accessibilityLabel`, `accessibilityTraits`, and `accessibilityHidden` without requiring a device or a human audit on every CI run. Wallapop's production stack uses snapshot-based integration tests; this demonstrates the same approach applied to accessibility.

---

## Exact-match search

PokéAPI has no partial-name search endpoint. `SearchPokemonUseCase` calls `GET /pokemon/{name|id}`, which returns exactly one result for an exact name or Pokédex number, or throws a 404 for anything else.

**Production alternative:** Pre-fetch the full names list (`GET /pokemon/?limit=100000`) once and cache it locally. Filter client-side as the user types. On commit, fetch the selected Pokémon's full data. This was not implemented here because it shifts a ~2 MB payload onto first launch and adds caching complexity that would obscure the architecture in a demo context.

---

## Sprite URL construction for list items

The paginated list endpoint (`GET /pokemon/?limit=N&offset=M`) returns only `name` and `url` (a resource URL like `https://pokeapi.co/api/v2/pokemon/1/`), with no sprite included. Two options:

1. Fire a separate `GET /pokemon/{id}` per row to get the sprite.
2. Extract the ID from the resource URL and construct the sprite URL from the known GitHub sprites CDN path.

Option 1 would fire 20+ concurrent requests on every page load. Option 2 is a single derivation with no network cost. The CDN URL pattern is stable and publicly documented. This is noted as a limitation in the README because it introduces a dependency on the CDN that a production app with a richer backend would avoid.

---

## SwiftLint and SwiftFormat

Both linters run as Xcode Run Script build phases, not as SPM framework dependencies. Using SPM framework targets causes iOS minimum-version linker errors because the tools bring in macOS-targeted binaries. The build scripts prepend `/opt/homebrew/bin` to `PATH` so Xcode's restricted environment finds the Homebrew-installed binaries.

Notable config decisions:
- **Line length 160 / 200** — UIKit delegate method signatures exceed 120 characters without artificial line breaks.
- **`force_unwrapping` opt-in** — flags `!` in production code. The codebase is already free of force unwraps; this rule acts as a regression guard.
- **Tests excluded from SwiftLint** — test files legitimately use `force_try` (Quick's `expect(try ...)` pattern) and `@testable import`, which would otherwise produce false warnings.
- **`--header ignore` in SwiftFormat** — preserves `// Created by` file headers.

---

## GitHub Actions CI

A single workflow (`ios.yml`) runs on every push and pull request to `main` and `develop`. It builds and runs all tests on `macos-latest` using an iPhone 16 simulator. `-skipPackagePluginValidation` is required because the swift-openapi-generator build plugin is not code-signed in the CI environment.

Test results are uploaded as an artifact on every run (including failures) for post-run inspection.

---

## Pokémon cry audio

PokéAPI provides Pokémon cries as `.ogg` (Vorbis) files, which AVFoundation cannot decode natively on iOS. Rather than add a third-party OGG decoder (which would require pinning to an untagged branch), the detail screen streams MP3 cries from the Pokémon Showdown CDN (`play.pokemonshowdown.com`). This is a third-party dependency on an unofficial CDN — acceptable for a demo, not for production.

`PokemonSoundPlayer` is an `@MainActor ObservableObject` that wraps `AVPlayer`. It uses a Combine `NotificationCenter` publisher to detect playback end and reset `isPlaying`, demonstrating reactive patterns without requiring RxSwift.
