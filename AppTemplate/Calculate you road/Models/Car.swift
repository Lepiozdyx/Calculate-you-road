import Foundation
import SwiftData

@Model
final class Car {
    var name: String
    var consumptionPer100km: Double
    var fuelTypeRaw: String

    var fuelType: FuelType {
        get { FuelType.fromStored(fuelTypeRaw) }
        set { fuelTypeRaw = newValue.rawValue }
    }

    init(
        name: String,
        consumptionPer100km: Double,
        fuelType: FuelType
    ) {
        self.name = name
        self.consumptionPer100km = consumptionPer100km
        self.fuelTypeRaw = fuelType.rawValue
    }
}
