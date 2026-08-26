import Foundation
import MapKit
import UIKit

enum MapRouteError: LocalizedError {
    case emptyOrigin
    case emptyDestination
    case geocodingFailed(String)
    case directionsFailed

    var errorDescription: String? {
        switch self {
        case .emptyOrigin:
            return "Please enter an origin city."
        case .emptyDestination:
            return "Please enter a destination city."
        case .geocodingFailed(let place):
            return "Could not find location for \"\(place)\"."
        case .directionsFailed:
            return "Could not calculate route distance. You can enter distance manually."
        }
    }
}

enum MapRouteService {
    static func calculateDistanceKm(from origin: String, to destination: String) async throws -> Double {
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedOrigin.isEmpty else { throw MapRouteError.emptyOrigin }
        guard !trimmedDestination.isEmpty else { throw MapRouteError.emptyDestination }

        let sourceItem = try await searchMapItem(for: trimmedOrigin)
        let destinationItem = try await searchMapItem(for: trimmedDestination)

        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw MapRouteError.directionsFailed
        }

        return route.distance / 1000
    }

    static func openRouteInMaps(from origin: String, to destination: String) async throws {
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedOrigin.isEmpty, !trimmedDestination.isEmpty else { return }

        let sourceItem = try await searchMapItem(for: trimmedOrigin)
        let destinationItem = try await searchMapItem(for: trimmedDestination)

        MKMapItem.openMaps(
            with: [sourceItem, destinationItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    private static func searchMapItem(for query: String) async throws -> MKMapItem {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let item = response.mapItems.first else {
            throw MapRouteError.geocodingFailed(query)
        }

        return item
    }
}
