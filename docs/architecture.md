# Architecture

## Overview

The app is structured around Clean Architecture with MVVM in the presentation layer. The dependency rule flows strictly inward: the domain layer knows nothing about UIKit, SwiftUI, networking, or persistence.

```
┌─────────────────────────────────────────────┐
│  Presentation (SwiftUI + MVVM)              │
│  PokemonListView / PokemonDetailView        │
│  PokemonListViewModel / PokemonDetailViewModel │
└───────────────────┬─────────────────────────┘
                    │ Use Case protocols
┌───────────────────▼─────────────────────────┐
│  Domain                                     │
│  Pokemon, PokemonDetail (value types)       │
│  GetPokemonListUseCase, SearchPokemonUseCase│
│  GetPokemonDetailUseCase, etc.              │
└───────────────────┬─────────────────────────┘
                    │ Repository protocols
┌───────────────────▼─────────────────────────┐
│  Data                                       │
│  PokemonRepository, FavoritesRepository     │
│  OpenAPIPokemonNetworkService               │
│  FavoritePokemon (Realm Object)             │
└─────────────────────────────────────────────┘
```

## Layers

### Domain

Pure Swift value types and protocols with no framework imports.

- `Pokemon` — `id`, `name`, `imageURL`
- `PokemonDetail` — `id`, `name`, `slug`, `imageURL`, `height`, `weight`, `types`, `stats`, `abilities`
- One use case struct per action, each conforming to its own protocol:
  - `GetPokemonListUseCaseProtocol` / `GetPokemonListUseCase`
  - `GetPokemonDetailUseCaseProtocol` / `GetPokemonDetailUseCase`
  - `SearchPokemonUseCaseProtocol` / `SearchPokemonUseCase`
  - `GetPokemonByTypeUseCaseProtocol` / `GetPokemonByTypeUseCase`
  - `GetPokemonTypesUseCaseProtocol` / `GetPokemonTypesUseCase`
  - `ToggleFavoriteUseCaseProtocol` / `ToggleFavoriteUseCase`
  - `GetFavoritesUseCaseProtocol` / `GetFavoritesUseCase`
- `PokemonRepositoryProtocol` and `FavoritesRepositoryProtocol`

### Data

#### Network

`PokemonNetworkServiceProtocol` decouples the repository from any specific API client.

Two concrete implementations exist:

**`OpenAPIPokemonNetworkService`** (active)
- Uses Apple's Swift OpenAPI Generator with a vendored PokéAPI OpenAPI 3.1 spec (`openapi.yaml`).
- The generator produces a type-safe `Client` at build time; no hand-written `Codable` structs or URL construction.
- `OpenAPIPokemonDataMapper` converts generated `Components.Schemas` types to `PokemonDTO` / `PokemonDetailDTO`.
- For list items, the sprite URL is constructed from the Pokédex ID extracted from the resource URL, because the paginated list endpoint returns only `name` and `url`.

**`PokemonAPINetworkService`** (alternative)
- Wraps the `PokemonAPI` Swift package from kinkofer.
- Retained as a reference implementation to show the protocol boundary in practice — swapping the active implementation is a one-line change in `DependencyContainer`.

#### Persistence

- `FavoritesRepository` wraps Realm. `FavoritePokemon` is a `RealmSwift.Object` with `@Persisted` properties.
- `DependencyContainer.makeRealm()` attempts a default Realm and falls back to an in-memory store on failure, so the app degrades gracefully rather than crashing.

#### DTOs

`PokemonDTO` and `PokemonDetailDTO` are plain Swift structs that cross the network/repository boundary. They are never exposed to the domain or presentation layers; `PokemonRepository` maps them to domain models via `PokemonMapper`.

### Presentation

**MVVM with `@MainActor ObservableObject`.**

- `PokemonListViewModel` owns all list state: the paginated Pokémon array, type filter selection, search state, and favourites. `@Published private(set)` properties enforce one-way data flow — the view can only mutate state through explicit ViewModel methods.
- `PokemonDetailViewModel` owns detail loading state and favourite toggle for a single Pokémon.
- Views subscribe to `@Published` properties and call `async` ViewModel methods via `Task { }` or `.task {}`.

**Pagination** is triggered inside the `List` via `.task` on each row. When the current row is within 5 items of the end and no load is in flight, `loadMoreIfNeeded` fires an append page.

**Search** is exact-match only — PokéAPI provides no partial-name search endpoint. The search bar calls `GET /pokemon/{name|id}` on submit.

**Type filter** calls `GET /type/{name}` which returns all Pokémon of that type — full server-side filtering, no client-side intersection.

**Favourites** are read from Realm synchronously (no async needed for a local store). The `showingFavoritesOnly` flag and `selectedType` filter are mutually exclusive; activating one clears the other.

### Dependency Injection

`DependencyContainer` is an `ObservableObject` created once in `SceneDelegate` and injected into the SwiftUI environment via `.environmentObject(container)`. It exposes factory methods (`makePokemonListViewModel()`, `makePokemonDetailViewModel(pokemonID:)`) rather than vending singletons, so each screen gets a fresh view model with the shared repositories underneath.

`PokemonDetailContainerView` resolves its view model from the environment using `@EnvironmentObject`. This allows `NavigationStack` to push detail screens using plain `Int` (Pokédex ID) as the navigation value, with no need for the list to know about the detail's dependencies.

## Module structure

```
WallaMarvel/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift        # Root window, injects DependencyContainer
│   └── DependencyContainer.swift  # Factory + composition root
├── Core/
│   ├── Components/
│   │   └── ErrorAlertModifier.swift
│   └── Utilities/
│       └── AppLogger.swift        # os.Logger categories: network, ui, persistence
├── Data/
│   ├── Mapper/
│   │   ├── PokemonMapper.swift
│   │   └── PokemonMapperHelpers.swift
│   ├── Persistence/
│   │   └── FavoritePokemon.swift
│   └── Repositories/
│       ├── PokemonRepository.swift
│       └── FavoritesRepository.swift
├── Domain/
│   ├── Models/
│   │   ├── Pokemon.swift
│   │   └── PokemonDetail.swift
│   ├── Repositories/
│   │   ├── PokemonRepositoryProtocol.swift
│   │   └── FavoritesRepositoryProtocol.swift
│   └── UseCases/
│       ├── Protocols/             # One protocol file per use case
│       └── *.swift                # Concrete implementations
├── Features/
│   ├── PokemonList/
│   │   ├── Components/
│   │   │   └── PokemonRowView.swift
│   │   ├── PokemonListView.swift
│   │   └── PokemonListViewModel.swift
│   └── PokemonDetail/
│       ├── Components/            # Header, Info, Stats, Abilities sections
│       ├── PokemonDetailContainerView.swift
│       ├── PokemonDetailView.swift
│       ├── PokemonDetailViewModel.swift
│       └── PokemonSoundPlayer.swift
├── Network/
│   ├── DTO/
│   │   └── PokemonDTO.swift
│   ├── Mapper/
│   │   ├── OpenAPIPokemonDataMapper.swift
│   │   └── PokemonDataMapper.swift
│   ├── OpenAPIPokemonNetworkService.swift
│   ├── PokemonAPINetworkService.swift
│   └── PokemonNetworkServiceProtocol.swift
└── Shared/
    ├── Components/
    │   ├── PokemonSpriteView.swift
    │   └── PokemonTypeBadgeView.swift
    └── Extensions/
        ├── Color+PokemonType.swift
        └── String+PokemonType.swift
```
