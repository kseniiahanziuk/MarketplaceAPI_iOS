import Foundation

struct CreateReviewRequest: Codable {
    let productId: String
    let slug: String
    let reviewText: String
    let rating: Int
    let userName: String
    let deleted: Bool
    let updatedAt: String
    let reviewId: String
    
    init(productId: String, reviewText: String, rating: Int, userName: String) {
        self.productId = productId
        self.slug = "string"
        self.reviewText = reviewText
        self.rating = rating
        self.userName = userName
        self.deleted = false
        self.updatedAt = ISO8601DateFormatter().string(from: Date())
        self.reviewId = UUID().uuidString
    }
}
