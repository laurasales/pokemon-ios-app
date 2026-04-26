import SwiftUI

struct PokeBallView: View {
    var size: CGFloat = 100

    private var bandHeight: CGFloat {
        size * 0.12
    }
    private var centerButtonSize: CGFloat {
        size * 0.28
    }
    private var innerButtonSize: CGFloat {
        size * 0.16
    }
    private var strokeWidth: CGFloat {
        size * 0.06
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.red)
                .frame(width: size, height: size / 2)
                .offset(y: -(size / 4))

            Rectangle()
                .fill(Color.white)
                .frame(width: size, height: size / 2)
                .offset(y: size / 4)

            Rectangle()
                .fill(Color.black)
                .frame(width: size, height: bandHeight)

            Circle()
                .fill(Color.black)
                .frame(width: centerButtonSize, height: centerButtonSize)

            Circle()
                .fill(Color.white)
                .frame(width: innerButtonSize, height: innerButtonSize)

            Circle()
                .stroke(Color.black, lineWidth: strokeWidth)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
