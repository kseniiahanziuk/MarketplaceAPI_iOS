import Foundation

struct SearchResult {
    let id = UUID()
    let productId: String
    let matchedFields: [String]
    let score: Double
}
