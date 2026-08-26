import SwiftUI
import SwiftData

struct TripCardView: View {
    let trip: Trip
    var showFullRoute: Bool = true

    var body: some View {
        let breakdown = trip.breakdown

        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(showFullRoute ? trip.routeTitle : trip.routeTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    StatusBadge(status: trip.status)
                }

                Text("\(DateFormatterCache.tripListDate.string(from: trip.date)) · \(trip.days) days")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                HStack {
                    metricColumn(label: "Distance", value: "\(Int(trip.breakdown.effectiveKm)) km", valueColor: .white)
                    Spacer()
                    metricColumn(label: "Total", value: CurrencyFormatter.dollarsShort(breakdown.total), valueColor: AppTheme.gold)
                    Spacer()
                    metricColumn(label: "Per Person", value: CurrencyFormatter.dollarsShort(breakdown.perPerson), valueColor: .white)
                    Spacer()
                    metricColumn(label: "Car", value: trip.carShortName, valueColor: .white)
                }
            }
        }
    }

    private func metricColumn(label: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    TripCardView(
        trip: Trip(
            origin: "Chicago",
            destination: "Nashville",
            distanceKm: 780,
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
    )
    .padding()
    .background(AppTheme.background)
}
