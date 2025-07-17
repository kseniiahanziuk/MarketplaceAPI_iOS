import Foundation

struct ProductFilter: Equatable {
    var selectedCategories: Set<String> = ["All"]
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
            if let firstCategory = selectedCategories.first {
                params["category"] = firstCategory
                params["filter[category]"] = firstCategory
                params["categoryName"] = firstCategory
                
                print("Setting category filter to: \(firstCategory)")
            }
        }
        
        switch availabilityFilter {
        case .inStock:
            params["available"] = "true"
            params["filter[available]"] = "true"
            params["filter[availability]"] = "true"
        case .outOfStock:
            params["available"] = "false"
            params["filter[available]"] = "false"
            params["filter[availability]"] = "false"
        case .all:
            break
        }
        
        if priceRange.lowerBound > 0 {
            params["minPrice"] = String(Int(priceRange.lowerBound))
            params["filter[minPrice]"] = String(Int(priceRange.lowerBound))
        }
        if priceRange.upperBound < 100000 {
            params["maxPrice"] = String(Int(priceRange.upperBound))
            params["filter[maxPrice]"] = String(Int(priceRange.upperBound))
        }
        
        if !selectedBrands.isEmpty {
            if let firstBrand = selectedBrands.first {
                params["brand"] = firstBrand
                params["filter[brand]"] = firstBrand
                
                print("Setting brand filter to: \(firstBrand)")
            }
        }
        
        if !selectedColors.isEmpty {
            if let firstColor = selectedColors.first {
                params["color"] = firstColor
                params["filter[color]"] = firstColor
                
                print("Setting color filter to: \(firstColor)")
            }
        }
        
        print("Final query params: \(params)")
        return params
    }
    
    var hasActiveFilters: Bool {
        return !selectedCategories.contains("All") ||
               !selectedBrands.isEmpty ||
               !selectedColors.isEmpty ||
               priceRange.lowerBound > 0 ||
               priceRange.upperBound < 100000 ||
               availabilityFilter != .all ||
               sortBy != .name
    }
    
    var filterSummary: String {
        var components: [String] = []
        
        if !selectedCategories.contains("All") && !selectedCategories.isEmpty {
            components.append("\(selectedCategories.count) categories")
        }
        
        if !selectedBrands.isEmpty {
            components.append("\(selectedBrands.count) brands")
        }
        
        if !selectedColors.isEmpty {
            components.append("\(selectedColors.count) colors")
        }
        
        if priceRange.lowerBound > 0 || priceRange.upperBound < 100000 {
            components.append("₴\(Int(priceRange.lowerBound))-₴\(Int(priceRange.upperBound))")
        }
        
        if availabilityFilter != .all {
            components.append(availabilityFilter.displayName)
        }
        
        if sortBy != .name {
            components.append("Sort: \(sortBy.displayName)")
        }
        
        return components.isEmpty ? "No filters" : components.joined(separator: ", ")
    }
    
    mutating func reset() {
        selectedCategories = ["All"]
        selectedBrands = []
        selectedColors = []
        priceRange = 0...100000
        sortBy = .name
        availabilityFilter = .all
    }
}
