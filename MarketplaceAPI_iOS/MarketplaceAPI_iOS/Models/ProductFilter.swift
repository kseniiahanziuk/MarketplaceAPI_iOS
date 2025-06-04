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
    
    var displayName: String { rawValue }
}

enum AvailabilityFilter: String, CaseIterable {
    case all = "All"
    case inStock = "In Stock"
    case outOfStock = "Out of Stock"
    
    var displayName: String { rawValue }
}
