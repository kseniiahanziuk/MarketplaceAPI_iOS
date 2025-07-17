import Foundation

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

