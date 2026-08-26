import Foundation

enum FuelType: String, CaseIterable, Codable, Identifiable {
    case petrol = "Petrol"
    case diesel = "Diesel"
    case premium = "Premium"
    case lpg = "LPG"
    case electric = "Electric"

    var id: String { rawValue }

    static func fromStored(_ raw: String) -> FuelType {
        if let type = FuelType(rawValue: raw) {
            return type
        }

        switch raw {
        case "AI-92", "AI-95":
            return .petrol
        case "AI-98":
            return .premium
        case "Gas", "Methane":
            return .lpg
        default:
            return .petrol
        }
    }
}
