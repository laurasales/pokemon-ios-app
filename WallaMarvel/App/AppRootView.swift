import SwiftUI

struct AppRootView: View {
    let pokemonListViewModel: PokemonListViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            PokemonListView(viewModel: pokemonListViewModel)
            if showSplash {
                SplashView(isVisible: $showSplash)
                    .zIndex(1)
            }
        }
    }
}
