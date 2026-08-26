import SwiftUI
import SwiftData

enum TripFormMode {
    case create
    case edit(Trip)

    var navigationTitle: String {
        switch self {
        case .create: return "New Trip"
        case .edit: return "Edit Trip"
        }
    }

    var saveButtonTitle: String {
        switch self {
        case .create: return "Save Trip"
        case .edit: return "Update Trip"
        }
    }
}

struct TripFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Car.name) private var cars: [Car]

    let mode: TripFormMode

    @State private var origin = ""
    @State private var destination = ""
    @State private var distanceKm = ""
    @State private var isRoundTrip = false
    @State private var date = Date.now
    @State private var days = 1
    @State private var peopleCount = 1
    @State private var selectedCarID: PersistentIdentifier?
    @State private var consumptionPer100km = ""
    @State private var fuelPricePerLiter = ""
    @State private var food = ""
    @State private var accommodation = ""
    @State private var entertainment = ""
    @State private var tolls = ""
    @State private var other = ""
    @State private var isCalculatingDistance = false
    @State private var showMapError = false
    @State private var mapErrorMessage = ""

    private var selectedCar: Car? {
        guard let selectedCarID else { return nil }
        return cars.first { $0.persistentModelID == selectedCarID }
    }

    private var breakdown: TripBreakdown {
        TripCalculator.breakdown(
            distanceKm: Double(distanceKm) ?? 0,
            isRoundTrip: isRoundTrip,
            consumptionPer100km: Double(consumptionPer100km) ?? 0,
            fuelPricePerLiter: Double(fuelPricePerLiter) ?? 0,
            food: Double(food) ?? 0,
            accommodation: Double(accommodation) ?? 0,
            entertainment: Double(entertainment) ?? 0,
            tolls: Double(tolls) ?? 0,
            other: Double(other) ?? 0,
            days: days,
            peopleCount: peopleCount
        )
    }

    private var canSave: Bool {
        !origin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Double(distanceKm) ?? 0) > 0 &&
        selectedCar != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                routeSection
                carFuelSection
                expensesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 180)
        }
        .background(AppTheme.background)
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneToolbar()
        .overlay(alignment: .bottom) {
            summaryBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear(perform: loadInitialValues)
        .alert("Route Error", isPresented: $showMapError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(mapErrorMessage)
        }
    }

    private var routeSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Route")

                formField(title: "From", text: $origin, placeholder: "Origin city")
                formField(title: "To", text: $destination, placeholder: "Destination city")
                formField(title: "Distance (km)", text: $distanceKm, placeholder: "0", keyboard: .decimalPad)

                Button {
                    Task { await calculateDistance() }
                } label: {
                    HStack {
                        if isCalculatingDistance {
                            ProgressView()
                                .tint(AppTheme.gold)
                        } else {
                            Image(systemName: "map")
                        }
                        Text("Calculate in Apple Maps")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppTheme.gold, lineWidth: 1)
                    )
                }
                .disabled(isCalculatingDistance)

                Toggle("Round Trip", isOn: $isRoundTrip)
                    .tint(AppTheme.gold)

                DatePicker("Trip Date", selection: $date, displayedComponents: .date)
                    .tint(AppTheme.gold)

                Stepper("Number of Days: \(days)", value: $days, in: 1...30)
                    .foregroundStyle(.white)

                Stepper("People: \(peopleCount)", value: $peopleCount, in: 1...8)
                    .foregroundStyle(.white)
            }
        }
    }

    private var carFuelSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Car & Fuel")

                if cars.isEmpty {
                    Text("Add a car in Profile to continue.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                } else {
                    VStack(spacing: 8) {
                        ForEach(cars) { car in
                            carRow(car)
                        }
                    }
                }

                formField(title: "Fuel Consumption", text: $consumptionPer100km, placeholder: "0", keyboard: .decimalPad, suffix: "L/100km")
                formField(title: "Fuel Price", text: $fuelPricePerLiter, placeholder: "0", keyboard: .decimalPad, suffix: "$/L")

                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated Fuel Cost")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)
                    Text(CurrencyFormatter.dollars(breakdown.fuelCost, decimals: 2))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text(String(format: "%.1f L • %@", breakdown.liters, CurrencyFormatter.dollars(Double(fuelPricePerLiter) ?? 0, decimals: 2) + "/L"))
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(AppTheme.gold.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var expensesSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Expenses")

                expenseRow(icon: "fork.knife", title: "Food", text: $food)
                expenseRow(icon: "building.2", title: "Accommodation", text: $accommodation)
                expenseRow(icon: "music.note", title: "Entertainment", text: $entertainment)
                expenseRow(icon: "creditcard", title: "Tolls", text: $tolls)
                expenseRow(icon: "plus", title: "Other", text: $other)
            }
        }
    }

    private var summaryBar: some View {
        VStack(spacing: 12) {
            HStack {
                summaryColumn(title: "Total", value: CurrencyFormatter.dollarsShort(breakdown.total), highlight: true)
                Spacer()
                summaryColumn(title: "Fuel", value: CurrencyFormatter.dollarsShort(breakdown.fuelCost))
                Spacer()
                summaryColumn(title: "Per Day", value: CurrencyFormatter.dollarsShort(breakdown.perDay))
            }

            PrimaryButton(title: mode.saveButtonTitle, isEnabled: canSave) {
                saveTrip()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func carRow(_ car: Car) -> some View {
        let isSelected = selectedCarID == car.persistentModelID

        return Button {
            selectedCarID = car.persistentModelID
            consumptionPer100km = String(format: "%.1f", car.consumptionPer100km)
        } label: {
            HStack {
                Text(car.name)
                    .foregroundStyle(isSelected ? AppTheme.gold : .white)
                    .fontWeight(.semibold)
                Spacer()
                Text(car.fuelType.rawValue)
                    .foregroundStyle(AppTheme.secondaryText)
                    .font(.subheadline)
            }
            .padding(12)
            .background(AppTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? AppTheme.gold : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func formField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default,
        suffix: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            HStack {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .foregroundStyle(.white)
                if let suffix {
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .padding(12)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func expenseRow(icon: String, title: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.white)
            Spacer()
            Text("$")
                .foregroundStyle(AppTheme.secondaryText)
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .foregroundStyle(.white)
        }
    }

    private func summaryColumn(title: String, value: String, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(highlight ? AppTheme.gold : .white)
        }
    }

    private func loadInitialValues() {
        if case .create = mode, let firstCar = cars.first {
            selectedCarID = firstCar.persistentModelID
            consumptionPer100km = String(format: "%.1f", firstCar.consumptionPer100km)
        }

        if case .edit(let trip) = mode {
            origin = trip.origin
            destination = trip.destination
            distanceKm = String(format: "%.0f", trip.distanceKm)
            isRoundTrip = trip.isRoundTrip
            date = trip.date
            days = trip.days
            peopleCount = trip.peopleCount
            consumptionPer100km = String(format: "%.1f", trip.consumptionPer100km)
            fuelPricePerLiter = String(format: "%.2f", trip.fuelPricePerLiter)
            food = trip.food > 0 ? String(format: "%.0f", trip.food) : ""
            accommodation = trip.accommodation > 0 ? String(format: "%.0f", trip.accommodation) : ""
            entertainment = trip.entertainment > 0 ? String(format: "%.0f", trip.entertainment) : ""
            tolls = trip.tolls > 0 ? String(format: "%.0f", trip.tolls) : ""
            other = trip.other > 0 ? String(format: "%.0f", trip.other) : ""

            if let car = cars.first(where: { $0.name == trip.carName }) {
                selectedCarID = car.persistentModelID
            }
        }
    }

    private func calculateDistance() async {
        isCalculatingDistance = true
        defer { isCalculatingDistance = false }

        do {
            let km = try await MapRouteService.calculateDistanceKm(from: origin, to: destination)
            distanceKm = String(format: "%.0f", km)
        } catch {
            mapErrorMessage = error.localizedDescription
            showMapError = true
        }
    }

    private func saveTrip() {
        guard let selectedCar else { return }

        switch mode {
        case .create:
            let trip = Trip(
                origin: origin.trimmingCharacters(in: .whitespacesAndNewlines),
                destination: destination.trimmingCharacters(in: .whitespacesAndNewlines),
                distanceKm: Double(distanceKm) ?? 0,
                isRoundTrip: isRoundTrip,
                date: date,
                days: days,
                peopleCount: peopleCount,
                carName: selectedCar.name,
                consumptionPer100km: Double(consumptionPer100km) ?? selectedCar.consumptionPer100km,
                fuelPricePerLiter: Double(fuelPricePerLiter) ?? 0,
                food: Double(food) ?? 0,
                accommodation: Double(accommodation) ?? 0,
                entertainment: Double(entertainment) ?? 0,
                tolls: Double(tolls) ?? 0,
                other: Double(other) ?? 0
            )
            modelContext.insert(trip)

        case .edit(let trip):
            trip.origin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.distanceKm = Double(distanceKm) ?? 0
            trip.isRoundTrip = isRoundTrip
            trip.date = date
            trip.days = days
            trip.peopleCount = peopleCount
            trip.carName = selectedCar.name
            trip.consumptionPer100km = Double(consumptionPer100km) ?? selectedCar.consumptionPer100km
            trip.fuelPricePerLiter = Double(fuelPricePerLiter) ?? 0
            trip.food = Double(food) ?? 0
            trip.accommodation = Double(accommodation) ?? 0
            trip.entertainment = Double(entertainment) ?? 0
            trip.tolls = Double(tolls) ?? 0
            trip.other = Double(other) ?? 0
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TripFormView(mode: .create)
    }
    .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
