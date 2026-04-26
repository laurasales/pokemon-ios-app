# Decisions

Key architectural and tooling choices, with rationale.

---

## Replacing the starter project

The original skeleton used Marvel's API, MVP, and UIKit with known intentional errors. Rather than patch it incrementally, I replaced the entire implementation to present a coherent architectural vision and to avoid inheriting structural debt that would complicate the technical discussion during the interview.

---

## SwiftUI over UIKit

I chose SwiftUI for the entire UI for several reasons:

- Listed as a "nice to have" in the tech challenge requirements.
- `NavigationStack`, `.searchable`, `.task`, and `.refreshable` eliminate significant boilerplate compared to their UIKit equivalents, leaving the code focused on product logic rather than plumbing.

---

## MVVM over MVP

The original skeleton used MVP. I switched to MVVM because:

- `@Published` + `ObservableObject` is SwiftUI's native data-binding model; wiring a separate `Presenter` protocol through `@EnvironmentObject` would add indirection without benefit.
- Every use-case and repository boundary remains behind a protocol, so testability is not reduced — view models are tested in isolation via mock use cases, the same guarantee MVP was providing.

---

## Swift OpenAPI Generator (active network implementation)

I serve the paginated list, detail, search, and type endpoints through `OpenAPIPokemonNetworkService`, generated from a vendored PokéAPI OpenAPI 3.1 spec using Apple's `swift-openapi-generator`.

**Why this over hand-written networking:**
- Zero hand-written `Codable` structs or URL construction for covered endpoints.
- The compiler validates the request/response contract at build time; a spec update immediately surfaces breaking changes as compile errors.
- Demonstrates familiarity with modern Apple tooling (introduced at WWDC 2023).

**Why I kept `PokemonAPINetworkService` as well:**
The third-party `PokemonAPI` wrapper was my first implementation. Keeping it alongside the OpenAPI version makes the `PokemonNetworkServiceProtocol` boundary tangible — swapping implementations is a one-line change in `DependencyContainer`. It also provides a fallback if the OpenAPI spec drifts from the live API.

---

## PokéAPI over Marvel API

I chose PokéAPI as the data source because:

- The tech challenge note says "feel free to use another API" if Marvel has issues — and Marvel's API has known reliability problems.
- PokéAPI is free, requires no API key, has a public OpenAPI spec, and has comprehensive endpoints (list, detail, types, search by name/ID).

---

## Realm for favourites persistence

I chose Realm over CoreData for the favourites store because:

- Realm's object model requires less boilerplate than CoreData's `NSManagedObject` for a simple persisted list.
- `FavoritesRepository` wraps Realm behind `FavoritesRepositoryProtocol`, so the persistence technology is swappable without touching the domain or presentation layers.
- It's a good opportunity to demonstrate Realm, which is widely used in production iOS apps alongside CoreData.

I added an in-memory Realm fallback in `DependencyContainer` so the app degrades gracefully if the on-disk store fails to initialise, rather than crashing at launch.

---

## Quick + Nimble for unit tests

I chose Quick + Nimble to demonstrate BDD-style testing, which is a common and readable pattern in larger iOS codebases. The view model tests use:

- `AsyncSpec` subclasses with `describe` / `context` / `it` blocks.
- `@MainActor` factory functions in spec scope isolate each example.
- Each mock use case is a simple struct that either returns a preconfigured value or throws a preconfigured error — no third-party mocking framework needed.

---

## Accessibility snapshot tests

I added `AccessibilitySnapshot` (CashApp) to snapshot-test the accessibility tree of shared components (`PokemonRowView`, `PokemonTypeBadgeView`, and the detail section views). This catches regressions in `accessibilityLabel`, `accessibilityTraits`, and `accessibilityHidden` without requiring a device or a manual audit on every run — the same principle as visual snapshot tests, applied specifically to accessibility.

---

## Exact-match search

PokéAPI has no partial-name search endpoint. `SearchPokemonUseCase` calls `GET /pokemon/{name|id}`, which returns exactly one result for an exact name or Pokédex number, or throws a 404 for anything else.

**Production alternative I considered:** Pre-fetch the full names list (`GET /pokemon/?limit=100000`) once and cache it locally. Filter client-side as the user types, then fetch the full Pokémon object on commit. I didn't implement this because it shifts a ~2 MB payload onto first launch and adds caching complexity that would obscure the architecture in a demo context.

---

## Sprite URL construction for list items

The paginated list endpoint (`GET /pokemon/?limit=N&offset=M`) returns only `name` and `url` (a resource URL like `https://pokeapi.co/api/v2/pokemon/1/`), with no sprite data. I had two options:

1. Fire a separate `GET /pokemon/{id}` per row to get the sprite.
2. Extract the ID from the resource URL and construct the sprite URL from the known GitHub sprites CDN path.

I chose option 2. Option 1 would fire 20+ concurrent requests on every page load. Option 2 is a single string derivation with no network cost. The CDN URL pattern is stable and publicly documented. I noted this as a limitation in the README because it introduces a CDN dependency that a production app with a richer backend would avoid.

---

## SwiftLint and SwiftFormat

I run both linters as Xcode Run Script build phases rather than as SPM framework plugins. Using SPM framework targets causes iOS minimum-version linker errors because the tools bring in macOS-targeted binaries. The build scripts prepend `/opt/homebrew/bin` to `PATH` so Xcode's restricted environment finds the Homebrew-installed binaries.

Notable config decisions:
- **Line length 160 / 200** — some method signatures exceed 120 characters without artificial line breaks that hurt readability.
- **`force_unwrapping` opt-in** — flags `!` in production code. The codebase is already free of force unwraps; this acts as a regression guard.
- **Tests excluded from SwiftLint** — test files legitimately use `force_try` (Quick's `expect(try ...)` pattern) and `@testable import`, which would otherwise produce false warnings.
- **`--header ignore` in SwiftFormat** — preserves `// Created by` file headers.

---

## Pokémon cry audio

PokéAPI provides Pokémon cries as `.ogg` (Vorbis) files, which AVFoundation cannot decode natively on iOS. Rather than add a third-party OGG decoder (which would require pinning to an untagged branch and adding a dependency I can't fully own), I stream MP3 cries from the Pokémon Showdown CDN (`play.pokemonshowdown.com`). This is a third-party dependency on an unofficial CDN — acceptable for a demo, not for production.

`PokemonSoundPlayer` is an `@MainActor ObservableObject` that wraps `AVPlayer`. It uses a Combine `NotificationCenter` publisher to detect playback end and reset `isPlaying`, demonstrating reactive patterns without requiring RxSwift.
