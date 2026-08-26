import Foundation
import SwiftData

enum MockData {
    private static let seedKey = "hasSeededMockData"

    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        guard AppConfig.useMockData else { return }
        guard !UserDefaults.standard.bool(forKey: seedKey) else { return }

        let camry = Car(name: "Toyota Camry 2022", consumptionPer100km: 7.2, fuelType: .petrol)
        let ford = Car(name: "Ford F-150", consumptionPer100km: 12.4, fuelType: .petrol)

        context.insert(camry)
        context.insert(ford)

        let chicagoTrip = Trip(
            origin: "Chicago",
            destination: "Nashville",
            distanceKm: 780,
            isRoundTrip: false,
            date: DateFormatterCache.tripDate.date(from: "2024-05-01") ?? .now,
            days: 4,
            peopleCount: 2,
            carName: "Ford F-150",
            consumptionPer100km: 12.4,
            fuelPricePerLiter: 1.38,
            food: 280,
            accommodation: 480,
            entertainment: 150,
            tolls: 20,
            other: 60
        )

        let nyTrip = Trip(
            origin: "New York",
            destination: "Boston",
            distanceKm: 346,
            isRoundTrip: false,
            date: DateFormatterCache.tripDate.date(from: "2024-06-15") ?? .now,
            days: 2,
            peopleCount: 2,
            carName: "Toyota Camry 2022",
            consumptionPer100km: 7.2,
            fuelPricePerLiter: 1.45,
            food: 120,
            accommodation: 200,
            entertainment: 80,
            tolls: 35,
            other: 20
        )

        context.insert(chicagoTrip)
        context.insert(nyTrip)

        try? context.save()
        UserDefaults.standard.set(true, forKey: seedKey)
    }
}
