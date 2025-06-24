import Foundation

struct ProductFilter {
    var selectedCategories: Set<String> = []
    var selectedBrands: Set<String> = []
    var selectedColors: Set<String> = []
    var priceRange: ClosedRange<Double> = 0...100000
    var sortBy: SortOption = .name
    var availabilityFilter: AvailabilityFilter = .all
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case priceAsc = "Price: ascending"
    case priceDesc = "Price: descending"
    case rating = "Rating"
    
    var displayName: String {
        switch self {
        case .name:
            return String(localized: "Name")
        case .priceAsc:
            return String(localized: "Price: ascending")
        case .priceDesc:
            return String(localized: "Price: descending")
        case .rating:
            return String(localized: "Rating")
        }
    }
}

enum AvailabilityFilter: String, CaseIterable {
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
