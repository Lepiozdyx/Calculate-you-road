import SwiftUI
import SwiftData
import Charts

struct ExpenseCategoryData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct TripSpendingData: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct CarMileageData: Identifiable {
    let id = UUID()
    let name: String
    let distance: Double
}

struct AnalyticsView: View {
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]

    private var totalTrips: Int { trips.count }
    private var totalDistance: Double {
        trips.reduce(0) { $0 + $1.breakdown.effectiveKm }
    }
    private var totalSpent: Double {
        trips.reduce(0) { $0 + $1.breakdown.total }
    }
    private var avgTripCost: Double {
        guard totalTrips > 0 else { return 0 }
        return totalSpent / Double(totalTrips)
    }
    private var totalFuel: Double {
        trips.reduce(0) { $0 + $1.breakdown.fuelCost }
    }
    private var fuelShare: Double {
        guard totalSpent > 0 else { return 0 }
        return (totalFuel / totalSpent) * 100
    }
    private var avgCostPerKm: Double {
        guard totalDistance > 0 else { return 0 }
        return totalSpent / totalDistance
    }

    private var expenseCategories: [ExpenseCategoryData] {
        let fuel = trips.reduce(0) { $0 + $1.breakdown.fuelCost }
        let food = trips.reduce(0) { $0 + $1.food }
        let hotel = trips.reduce(0) { $0 + $1.accommodation }
        let entertain = trips.reduce(0) { $0 + $1.entertainment }
        let tolls = trips.reduce(0) { $0 + $1.tolls }
        let other = trips.reduce(0) { $0 + $1.other }

        return [
            ExpenseCategoryData(name: "Fuel", amount: fuel, color: AppTheme.gold),
            ExpenseCategoryData(name: "Food", amount: food, color: .green),
            ExpenseCategoryData(name: "Hotel", amount: hotel, color: .blue),
            ExpenseCategoryData(name: "Entertain", amount: entertain, color: .purple),
            ExpenseCategoryData(name: "Tolls", amount: tolls, color: .orange),
            ExpenseCategoryData(name: "Other", amount: other, color: .red)
        ].filter { $0.amount > 0 }
    }

    private var tripSpending: [TripSpendingData] {
        trips.map { trip in
            TripSpendingData(label: trip.shortRouteTitle, amount: trip.breakdown.total)
        }
    }

    private var topCars: [CarMileageData] {
        var mileage: [String: Double] = [:]
        for trip in trips {
            mileage[trip.carName, default: 0] += trip.breakdown.effectiveKm
        }
        return mileage
            .map { CarMileageData(name: $0.key, distance: $0.value) }
            .sorted { $0.distance > $1.distance }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            metricsGrid
                            expenseCategoriesCard
                            spendingPerTripCard
                            topCarsCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Your Statistics")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.gold)
            Text("No statistics yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Complete a trip to see your analytics.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
        }
        .padding()
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(title: "Total Trips", value: "\(totalTrips)")
            metricCard(title: "Total Distance", value: "\(Int(totalDistance)) km")
            metricCard(title: "Total Spent", value: CurrencyFormatter.dollarsShort(totalSpent))
            metricCard(title: "Avg Trip Cost", value: CurrencyFormatter.dollarsShort(avgTripCost))
            metricCard(title: "Fuel Share", value: String(format: "%.0f%%", fuelShare))
            metricCard(title: "Avg Cost/KM", value: CurrencyFormatter.dollars(avgCostPerKm, decimals: 2))
        }
        .padding(.top, 8)
    }

    private func metricCard(title: String, value: String) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
                    .textCase(.uppercase)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
        }
    }

    private var expenseCategoriesCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Expense Categories")

                HStack(alignment: .center, spacing: 16) {
                    Chart(expenseCategories) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                    }
                    .frame(width: 120, height: 120)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(expenseCategories) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                Text(item.name)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                                Spacer()
                                Text(CurrencyFormatter.dollarsShort(item.amount))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
    }

    private var spendingPerTripCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Spending Per Trip")

                Chart(tripSpending) { item in
                    BarMark(
                        x: .value("Trip", item.label),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(AppTheme.gold)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
    }

    private var topCarsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Top Cars by Mileage")

                ForEach(Array(topCars.enumerated()), id: \.element.id) { index, car in
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundStyle(index == 0 ? AppTheme.gold : AppTheme.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.background)
                            .clipShape(Circle())

                        Text(car.name)
                            .foregroundStyle(index == 0 ? .white : AppTheme.secondaryText)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text("\(Int(car.distance)) km")
                            .foregroundStyle(index == 0 ? AppTheme.gold : AppTheme.secondaryText)
                            .font(.subheadline.weight(.semibold))
                    }

                    if index < topCars.count - 1 {
                        Divider().overlay(Color.white.opacity(0.1))
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
