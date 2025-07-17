import Foundation
import SwiftUI

struct Product: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let images: [String]
    let availability: ProductAvailability
    let category: String
    let tags: [String]
    let vendorId: String
    let brand: String
    let color: String
    let rating: Double
    let createdAt: String?
    let updatedAt: String?
    
    var mainImage: String { images.first ?? "photo" }
    var isAvailable: Bool { return availability == .inStock }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(
        id: String,
        name: String,
        description: String,
        price: Double,
        images: [String],
        availability: ProductAvailability,
        category: String,
        tags: [String],
        vendorId: String,
        brand: String,
        color: String,
        rating: Double,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.images = images
        self.availability = availability
        self.category = category
        self.tags = tags
        self.vendorId = vendorId
        self.brand = brand
        self.color = color
        self.rating = rating
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from apiResponse: [String: Any]) {
        self.id = apiResponse["productId"] as? String ?? apiResponse["id"] as? String ?? ""
        self.name = apiResponse["name"] as? String ?? ""
        self.description = apiResponse["description"] as? String ?? ""
        self.price = apiResponse["price"] as? Double ?? 0.0
        self.images = apiResponse["images"] as? [String] ?? ["photo"]
        
        if let availableBool = apiResponse["available"] as? Bool {
            self.availability = availableBool ? .inStock : .outOfStock
        } else if let availabilityBool = apiResponse["availability"] as? Bool {
            self.availability = availabilityBool ? .inStock : .outOfStock
        } else {
            self.availability = .inStock
        }
        
        self.category = apiResponse["category"] as? String ?? ""
        
        if let tagsString = apiResponse["tags"] as? String {
            self.tags = [tagsString]
        } else if let tagsArray = apiResponse["tags"] as? [String] {
            self.tags = tagsArray
        } else {
            self.tags = []
        }
        
        self.vendorId = apiResponse["vendorId"] as? String ?? ""
        
        self.brand = apiResponse["brand"] as? String ?? "Unknown Brand"
        self.color = apiResponse["color"] as? String ?? "Default"
        self.rating = apiResponse["rating"] as? Double ?? 4.0
        self.createdAt = apiResponse["createdAt"] as? String
        self.updatedAt = apiResponse["updatedAt"] as? String
    }
}
