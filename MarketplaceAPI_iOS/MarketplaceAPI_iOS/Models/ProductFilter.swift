import Foundation

struct ProductFilter: Equatable {
    var selectedCategories: Set<String> = []
    var selectedBrands: Set<String> = []
    var selectedColors: Set<String> = []
    var priceRange: ClosedRange<Double> = 0...100000
    var sortBy: SortOption = .name
    var availabilityFilter: AvailabilityFilter = .all
    
    static func == (lhs: ProductFilter, rhs: ProductFilter) -> Bool {
        return lhs.selectedCategories == rhs.selectedCategories &&
               lhs.selectedBrands == rhs.selectedBrands &&
               lhs.selectedColors == rhs.selectedColors &&
               lhs.priceRange.lowerBound == rhs.priceRange.lowerBound &&
               lhs.priceRange.upperBound == rhs.priceRange.upperBound &&
               lhs.sortBy == rhs.sortBy &&
               lhs.availabilityFilter == rhs.availabilityFilter
    }
    
    func toAPIQueryParams(page: Int = 0, size: Int = 20, searchTerm: String? = nil) -> [String: String] {
        var params: [String: String] = [
            "page": String(page),
            "size": String(size),
            "sortField": sortBy.apiFieldName,
            "direction": sortBy.apiDirection
        ]
        
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            params["filter[name]"] = searchTerm
        }
        
        if !selectedCategories.isEmpty && !selectedCategories.contains("All") {
            params["filter[category]"] = selectedCategories.first
        }
        
        switch availabilityFilter {
        case .inStock:
            params["filter[available]"] = "true"
        case .outOfStock:
            params["filter[available]"] = "false"
        case .all:
            break
        }
        
        if priceRange.lowerBound > 0 {
            params["filter[minPrice]"] = String(priceRange.lowerBound)
        }
        if priceRange.upperBound < 100000 {
            params["filter[maxPrice]"] = String(priceRange.upperBound)
        }
        
        if !selectedBrands.isEmpty {
            params["filter[brand]"] = selectedBrands.first
        }
        
        if !selectedColors.isEmpty {
            params["filter[color]"] = selectedColors.first
        }
        
        return params
    }
}

enum SortOption: String, CaseIterable, Equatable {
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
    
    var apiFieldName: String {
        switch self {
        case .name:
            return "name"
        case .priceAsc, .priceDesc:
            return "price"
        case .rating:
            return "rating"
        }
    }
    
    var apiDirection: String {
        switch self {
        case .name, .priceAsc:
            return "ASC"
        case .priceDesc, .rating:
            return "DESC"
        }
    }
}

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
