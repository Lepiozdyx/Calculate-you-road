import SwiftUI
import SwiftData

struct TripDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: Trip

    @State private var showDeleteAlert = false
    @State private var showEdit = false
    @State private var showMapError = false
    @State private var mapErrorMessage = ""

    private var breakdown: TripBreakdown { trip.breakdown }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                routeDetailsCard
                fuelCard
                expensesCard
                totalCard
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(AppTheme.background)
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showEdit) {
            TripFormView(mode: .edit(trip))
        }
        .alert("Delete Trip?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteTrip()
            }
        } message: {
            Text("This will permanently delete the \(trip.origin) → \(trip.destination) trip. This action cannot be undone.")
        }
        .alert("Maps Error", isPresented: $showMapError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(mapErrorMessage)
        }
    }

    private var summaryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    RouteTimeline(origin: trip.origin, destination: trip.destination)
                    Spacer()
                    StatusBadge(status: trip.status)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text(DateFormatterCache.tripDate.string(from: trip.date))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Days")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("\(trip.days)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("People")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("\(trip.peopleCount)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    private var routeDetailsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Route Details")
                DetailRow(label: "Distance", value: "\(Int(breakdown.effectiveKm)) km")
                DetailRow(label: "Car", value: trip.carName)
                DetailRow(label: "Round Trip", value: trip.isRoundTrip ? "Yes" : "No")
            }
        }
    }

    private var fuelCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Fuel Calculation")
                DetailRow(label: "Consumption", value: String(format: "%.1f L/100km", trip.consumptionPer100km))
                DetailRow(label: "Fuel Price", value: CurrencyFormatter.dollars(trip.fuelPricePerLiter, decimals: 2) + "/L")
                DetailRow(label: "Liters Required", value: String(format: "%.1f L", breakdown.liters))

                Divider().overlay(Color.white.opacity(0.1))

                HStack {
                    Text("Total Fuel Cost")
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                    Text(CurrencyFormatter.dollars(breakdown.fuelCost, decimals: 2))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                }
            }
        }
    }

    private var expensesCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Expenses")
                DetailRow(label: "Food", value: CurrencyFormatter.dollars(trip.food, decimals: 2))
                DetailRow(label: "Accommodation", value: CurrencyFormatter.dollars(trip.accommodation, decimals: 2))
                DetailRow(label: "Entertainment", value: CurrencyFormatter.dollars(trip.entertainment, decimals: 2))
                DetailRow(label: "Tolls", value: CurrencyFormatter.dollars(trip.tolls, decimals: 2))
                DetailRow(label: "Other", value: CurrencyFormatter.dollars(trip.other, decimals: 2))
            }
        }
    }

    private var totalCard: some View {
        AppCard {
            HStack {
                Text("Total Trip Cost")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(CurrencyFormatter.dollarsShort(breakdown.total))
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    showEdit = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Trip")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius))
                }
                .buttonStyle(.plain)

                ShareLink(item: shareText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius))
                }
            }

            SecondaryActionButton(title: "Open Route in Apple Maps", icon: "map") {
                Task { await openInMaps() }
            }

            SecondaryActionButton(title: "Delete Trip", icon: "trash", tint: AppTheme.destructive) {
                showDeleteAlert = true
            }
        }
        .padding(.bottom, 24)
    }

    private var shareText: String {
        """
        Trip: \(trip.origin) → \(trip.destination)
        Date: \(DateFormatterCache.tripDate.string(from: trip.date))
        Distance: \(Int(breakdown.effectiveKm)) km
        Total: \(CurrencyFormatter.dollarsShort(breakdown.total))
        Per Person: \(CurrencyFormatter.dollarsShort(breakdown.perPerson))
        Fuel: \(CurrencyFormatter.dollars(breakdown.fuelCost, decimals: 2))
        """
    }

    private func openInMaps() async {
        do {
            try await MapRouteService.openRouteInMaps(from: trip.origin, to: trip.destination)
        } catch {
            mapErrorMessage = error.localizedDescription
            showMapError = true
        }
    }

    private func deleteTrip() {
        modelContext.delete(trip)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TripDetailsView(
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
    }
    .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
