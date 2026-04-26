import SwiftUI

struct SplashView: View {
    @Binding var isVisible: Bool

    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            PokeBallView(size: 150)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
        }
        withAnimation(.linear(duration: 0.7).delay(0.4)) {
            rotation = 360
        }
        withAnimation(.easeIn(duration: 0.3).delay(1.2)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isVisible = false
        }
    }
}
