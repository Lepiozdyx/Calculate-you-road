import SwiftUI
import SwiftData

struct Calculate_you_roadApp: View {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Car.self, Trip.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some View {
        ContentView()
            .task {
                await seedMockData()
            }
            .modelContainer(sharedModelContainer)
    }

    @MainActor
    private func seedMockData() async {
        let context = sharedModelContainer.mainContext
        MockData.seedIfNeeded(context: context)
    }
}
