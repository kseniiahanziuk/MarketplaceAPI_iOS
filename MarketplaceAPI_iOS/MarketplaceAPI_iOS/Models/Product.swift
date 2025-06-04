import Foundation
import SwiftUI

struct Product: Codable, Identifiable {
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
    
    var mainImage: String { images.first ?? "photo" }
    var isAvailable: Bool {
        return availability == .inStock
    }
    
    static let sampleProducts = [
        Product(
            id: "1",
            name: "iPhone 15 Pro",
            description: "Новий iPhone з титановим корпусом та потужним процесором A17 Pro",
            price: 35999.0,
            images: ["phone"],
            availability: .inStock,
            category: "Електроніка",
            tags: ["apple", "smartphone", "ios"],
            vendorId: "vendor-1",
            brand: "Apple",
            color: "Титан",
            rating: 4.8
        ),
        Product(
            id: "2",
            name: "MacBook Air M3",
            description: "Потужний ноутбук для роботи з новим чіпом M3",
            price: 45999.0,
            images: ["laptopcomputer"],
            availability: .inStock,
            category: "Комп'ютери",
            tags: ["apple", "laptop", "macbook"],
            vendorId: "vendor-2",
            brand: "Apple",
            color: "Сріблястий",
            rating: 4.7
        ),
        Product(
            id: "3",
            name: "AirPods Pro",
            description: "Бездротові навушники з активним шумозаглушенням",
            price: 8999.0,
            images: ["airpods"],
            availability: .outOfStock,
            category: "Аксесуари",
            tags: ["apple", "headphones", "wireless"],
            vendorId: "vendor-1",
            brand: "Apple",
            color: "Білий",
            rating: 4.6
        ),
        Product(
            id: "4",
            name: "Samsung Galaxy S24",
            description: "Флагманський смартфон Samsung з AI функціями",
            price: 32999.0,
            images: ["phone"],
            availability: .inStock,
            category: "Електроніка",
            tags: ["samsung", "smartphone", "android"],
            vendorId: "vendor-3",
            brand: "Samsung",
            color: "Чорний",
            rating: 4.5
        ),
        Product(
            id: "5",
            name: "Xiaomi Redmi 7",
            description: "Телефон, який не шкода",
            price: 10299.0,
            images: ["phone"],
            availability: .inStock,
            category: "Електроніка",
            tags: ["xiaomi", "smartphone", "androir"],
            vendorId: "vendor-3",
            brand: "Xiaomi",
            color: "Білий",
            rating: 4.8
        )
    ]
}

enum ProductAvailability: String, Codable, CaseIterable {
    case inStock = "inStock"
    case outOfStock = "outOfStock"
    
    var displayName: String {
        switch self {
        case .inStock: return "Available"
        case .outOfStock: return "Not available"
        }
    }
    
    var color: Color {
        switch self {
        case .inStock: return .green
        case .outOfStock: return .red
        }
    }
}

