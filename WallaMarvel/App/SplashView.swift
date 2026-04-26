import SwiftUI

private struct StarData: Identifiable {
    let id = UUID()
    let x: CGFloat = .random(in: 0.04 ... 0.96)
    let y: CGFloat = .random(in: 0.04 ... 0.96)
    let size: CGFloat = .random(in: 1.5 ... 4.5)
    let delay: Double = .random(in: 0 ... 2)
    let duration: Double = .random(in: 0.6 ... 1.8)
    let isSparkle: Bool = .random()
}

private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.25
        var path = Path()

        for index in 0 ..< 8 {
            let angle = Double(index) * .pi / 4 - .pi / 2
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

private struct StarParticleView: View {
    let data: StarData
    let containerSize: CGSize
    @State private var twinkle = false

    var body: some View {
        Group {
            if data.isSparkle {
                SparkleShape()
                    .fill(Color.yellow.opacity(0.85))
                    .frame(width: data.size * 2.5, height: data.size * 2.5)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: data.size, height: data.size)
            }
        }
        .opacity(twinkle ? 0.15 : 0.9)
        .scaleEffect(twinkle ? 0.4 : 1.0)
        .position(
            x: data.x * containerSize.width,
            y: data.y * containerSize.height
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: data.duration)
                    .repeatForever(autoreverses: true)
                    .delay(data.delay)
            ) {
                twinkle = true
            }
        }
    }
}

struct SplashView: View {
    @Binding var isVisible: Bool

    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = 0
    @State private var contentOpacity: Double = 1
    @State private var glowRadius: CGFloat = 40
    @State private var glowOpacity: Double = 0
    @State private var ringScale: CGFloat = 1
    @State private var ringOpacity: Double = 0
    @State private var stars: [StarData] = (0 ..< 45).map { _ in StarData() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.12),
                        Color(red: 0.08, green: 0.04, blue: 0.18),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ForEach(stars) { star in
                    StarParticleView(data: star, containerSize: geo.size)
                }

                Circle()
                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)

                RadialGradient(
                    colors: [Color.red.opacity(0.55), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: glowRadius
                )
                .frame(width: glowRadius * 2, height: glowRadius * 2)
                .opacity(glowOpacity)
                .blur(radius: 14)

                PokeBallView(size: 150)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(contentOpacity)
                    .shadow(color: .red.opacity(0.65), radius: 28)
            }
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
            glowOpacity = 1
            glowRadius = 90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ringOpacity = 0.8
            withAnimation(.easeOut(duration: 0.8)) {
                ringScale = 3.0
                ringOpacity = 0
            }
        }

        withAnimation(.linear(duration: 0.7).delay(0.4)) {
            rotation = 360
        }

        withAnimation(.easeIn(duration: 0.4).delay(1.2)) {
            contentOpacity = 0
            glowOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            isVisible = false
        }
    }
}
