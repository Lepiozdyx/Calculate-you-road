import Foundation

struct TripBreakdown {
    let effectiveKm: Double
    let liters: Double
    let fuelCost: Double
    let total: Double
    let perPerson: Double
    let perDay: Double
}

enum TripCalculator {
    static func breakdown(
        distanceKm: Double,
        isRoundTrip: Bool,
        consumptionPer100km: Double,
        fuelPricePerLiter: Double,
        food: Double,
        accommodation: Double,
        entertainment: Double,
        tolls: Double,
        other: Double,
        days: Int,
        peopleCount: Int
    ) -> TripBreakdown {
        let effectiveKm = distanceKm * (isRoundTrip ? 2 : 1)
        let liters = effectiveKm * consumptionPer100km / 100
        let fuelCost = liters * fuelPricePerLiter
        let total = fuelCost + food + accommodation + entertainment + tolls + other
        let perPerson = total / Double(max(peopleCount, 1))
        let perDay = total / Double(max(days, 1))

        return TripBreakdown(
            effectiveKm: effectiveKm,
            liters: liters,
            fuelCost: fuelCost,
            total: total,
            perPerson: perPerson,
            perDay: perDay
        )
    }

    static func breakdown(for trip: Trip) -> TripBreakdown {
        breakdown(
            distanceKm: trip.distanceKm,
            isRoundTrip: trip.isRoundTrip,
            consumptionPer100km: trip.consumptionPer100km,
            fuelPricePerLiter: trip.fuelPricePerLiter,
            food: trip.food,
            accommodation: trip.accommodation,
            entertainment: trip.entertainment,
            tolls: trip.tolls,
            other: trip.other,
            days: trip.days,
            peopleCount: trip.peopleCount
        )
    }
}

enum CurrencyFormatter {
    static func dollars(_ value: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    static func dollarsShort(_ value: Double) -> String {
        dollars(value, decimals: value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2)
    }
}

enum DateFormatterCache {
    static let tripDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let tripListDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
