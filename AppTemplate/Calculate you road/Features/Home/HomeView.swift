import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]
    @State private var showNewTrip = false

    private var totalTrips: Int { trips.count }
    private var totalSpent: Double {
        trips.reduce(0) { $0 + $1.breakdown.total }
    }
    private var latestTrip: Trip? { trips.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    readyToGoCard
                        .padding(.top, 8)

                    statsRow

                    if let latestTrip {
                        latestTripSection(latestTrip)
                    } else {
                        emptyLatestTrip
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background)
            .navigationTitle("Calculate You Road")
            .navigationDestination(isPresented: $showNewTrip) {
                TripFormView(mode: .create)
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailsView(trip: trip)
            }
        }
    }

    private var readyToGoCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Ready to Go?")
                Text("Plan your next adventure")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                PrimaryButton(title: "Calculate a Trip") {
                    showNewTrip = true
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(title: "Total Trips", value: "\(totalTrips)")
            statCard(title: "Total Spent", value: CurrencyFormatter.dollarsShort(totalSpent))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func statCard(title: String, value: String) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)
                Spacer(minLength: 0)
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func latestTripSection(_ trip: Trip) -> some View {
        let breakdown = trip.breakdown

        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Latest Trip")

            NavigationLink(value: trip) {
                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            RouteTimeline(origin: trip.origin, destination: trip.destination)
                            Spacer()
                            StatusBadge(status: trip.status)
                        }

                        HStack {
                            metricColumn(label: "Distance", value: "\(Int(breakdown.effectiveKm)) km", valueColor: .white)
                            Spacer()
                            metricColumn(label: "Total Cost", value: CurrencyFormatter.dollarsShort(breakdown.total), valueColor: AppTheme.gold)
                            Spacer()
                            metricColumn(label: "Per Person", value: CurrencyFormatter.dollarsShort(breakdown.perPerson), valueColor: .white)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyLatestTrip: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Latest Trip")
                Text("No trips yet. Create your first trip to see it here.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    private func metricColumn(label: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
