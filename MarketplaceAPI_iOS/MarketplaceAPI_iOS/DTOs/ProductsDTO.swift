import Foundation

struct ProductDTO: Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let images: [String]?
    let availability: Bool
    let category: String
    let tags: [String]?
    let vendorId: String?
    let brand: String
    let color: String
    let rating: Double
    let createdAt: String?
    let updatedAt: String?
    
    func toDomainModel() -> Product {
        return Product(
            id: id,
            name: name,
            description: description,
            price: price,
            images: images ?? ["photo"],
            availability: availability ? .inStock : .outOfStock,
            category: category,
            tags: tags ?? [],
            vendorId: vendorId ?? "",
            brand: brand,
            color: color,
            rating: rating,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
