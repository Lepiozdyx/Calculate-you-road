import SwiftUI
import SwiftData

enum CarEditorMode: Identifiable {
    case add
    case edit(Car)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let car): return car.persistentModelID.hashValue.description
        }
    }

    var title: String {
        switch self {
        case .add: return "Add Car"
        case .edit: return "Edit Car"
        }
    }
}

struct CarEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: CarEditorMode

    @State private var name = ""
    @State private var consumption = "7.5"
    @State private var selectedFuelType: FuelType = .petrol

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Double(consumption) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Car Name")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        TextField("e.g. Toyota Camry 2022", text: $name)
                            .padding(12)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fuel Consumption (L/100km)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                        TextField("7.5", text: $consumption)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fuel Type")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)

                        FlowLayout(spacing: 8) {
                            ForEach(FuelType.allCases) { fuelType in
                                fuelChip(fuelType)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            }
            .keyboardDoneToolbar()
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Save Car", isEnabled: canSave) {
                    saveCar()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .onAppear(perform: loadValues)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private func fuelChip(_ fuelType: FuelType) -> some View {
        let isSelected = selectedFuelType == fuelType

        return Button {
            selectedFuelType = fuelType
        } label: {
            Text(fuelType.rawValue)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? AppTheme.gold : AppTheme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AppTheme.gold : Color.clear, lineWidth: 1.5)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func loadValues() {
        if case .edit(let car) = mode {
            name = car.name
            consumption = String(format: "%.1f", car.consumptionPer100km)
            selectedFuelType = car.fuelType
        }
    }

    private func saveCar() {
        let consumptionValue = Double(consumption) ?? 0

        switch mode {
        case .add:
            let car = Car(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                consumptionPer100km: consumptionValue,
                fuelType: selectedFuelType
            )
            modelContext.insert(car)

        case .edit(let car):
            car.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            car.consumptionPer100km = consumptionValue
            car.fuelType = selectedFuelType
        }

        try? modelContext.save()
        dismiss()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    CarEditorSheet(mode: .add)
        .modelContainer(for: [Car.self, Trip.self], inMemory: true)
}
