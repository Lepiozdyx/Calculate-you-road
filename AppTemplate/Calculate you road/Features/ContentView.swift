import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var hasCompletedOnboarding = OnboardingStorage.hasCompleted

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
