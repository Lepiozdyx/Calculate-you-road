import SwiftUI

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(AppTheme.gold)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(Color(white: 0.25))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}
