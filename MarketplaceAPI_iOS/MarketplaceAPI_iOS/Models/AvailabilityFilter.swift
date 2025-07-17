import Foundation

enum AvailabilityFilter: String, CaseIterable, Equatable {
    case all = "All"
    case inStock = "In stock"
    case outOfStock = "Out of stock"
    
    var displayName: String {
        switch self {
        case .all:
            return String(localized: "All")
        case .inStock:
            return String(localized: "In stock")
        case .outOfStock:
            return String(localized: "Out of stock")
        }
    }
}

