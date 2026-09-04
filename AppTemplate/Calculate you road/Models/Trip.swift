import Foundation
import SwiftData

enum TripStatus: String {
    case completed = "Completed"
    case upcoming = "Upcoming"

    static func from(date: Date) -> TripStatus {
        date <= .now ? .completed : .upcoming
    }
}

@Model
final class Trip {
    var origin: String
    var destination: String
    var distanceKm: Double
    var isRoundTrip: Bool
    var date: Date
    var days: Int
    var peopleCount: Int
    var carName: String
    var consumptionPer100km: Double
    var fuelPricePerLiter: Double
    var food: Double
    var accommodation: Double
    var entertainment: Double
    var tolls: Double
    var other: Double
    var emergencyBufferPercent: Int = 0

    init(
        origin: String = "",
        destination: String = "",
        distanceKm: Double = 0,
        isRoundTrip: Bool = false,
        date: Date = .now,
        days: Int = 1,
        peopleCount: Int = 1,
        carName: String = "",
        consumptionPer100km: Double = 0,
        fuelPricePerLiter: Double = 0,
        food: Double = 0,
        accommodation: Double = 0,
        entertainment: Double = 0,
        tolls: Double = 0,
        other: Double = 0,
        emergencyBufferPercent: Int = 0
    ) {
        self.origin = origin
        self.destination = destination
        self.distanceKm = distanceKm
        self.isRoundTrip = isRoundTrip
        self.date = date
        self.days = days
        self.peopleCount = peopleCount
        self.carName = carName
        self.consumptionPer100km = consumptionPer100km
        self.fuelPricePerLiter = fuelPricePerLiter
        self.food = food
        self.accommodation = accommodation
        self.entertainment = entertainment
        self.tolls = tolls
        self.other = other
        self.emergencyBufferPercent = emergencyBufferPercent
    }

    var status: TripStatus {
        TripStatus.from(date: date)
    }

    var routeTitle: String {
        "\(origin) → \(destination)"
    }

    var shortRouteTitle: String {
        let from = origin.split(separator: " ").first.map(String.init) ?? origin
        let to = destination.split(separator: " ").first.map(String.init) ?? destination
        return "\(from)→\(to)"
    }

    var carShortName: String {
        carName.split(separator: " ").first.map(String.init) ?? carName
    }

    var breakdown: TripBreakdown {
        TripCalculator.breakdown(for: self)
    }
}
