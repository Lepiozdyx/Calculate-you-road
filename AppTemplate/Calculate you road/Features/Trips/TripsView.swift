import SwiftUI
import SwiftData

struct TripsView: View {
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]
    @State private var showNewTrip = false

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(trips) { trip in
                                NavigationLink(value: trip) {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(AppTheme.background)
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewTrip = true
                    } label: {
                        Text("+ New Trip")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
            .navigationDestination(isPresented: $showNewTrip) {
                TripFormView(mode: .create)
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailsView(trip: trip)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.gold)
            Text("No trips yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Start planning your first road trip.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
            PrimaryButton(title: "Create Trip") {
                showNewTrip = true
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TripsView()
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
