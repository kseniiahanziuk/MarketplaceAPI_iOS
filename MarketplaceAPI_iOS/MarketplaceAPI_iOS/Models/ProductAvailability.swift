import Foundation
import SwiftUI

enum ProductAvailability: String, Codable, CaseIterable {
    case inStock = "inStock"
    case outOfStock = "outOfStock"
    
    var displayName: String {
        switch self {
        case .inStock: return String(localized: "Available")
        case .outOfStock: return String(localized: "Not available")
        }
    }
    
    var color: Color {
        switch self {
        case .inStock: return .green
        case .outOfStock: return .red
        }
    }
}

