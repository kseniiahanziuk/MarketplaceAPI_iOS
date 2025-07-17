import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let productId: String
    let slug: String
    let reviewText: String
    let rating: Int
    let userName: String
    let deleted: Bool
    let updatedAt: String
    let reviewId: String
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: updatedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return updatedAt
    }
    
    var updatedAtDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: updatedAt) ?? Date()
    }
    
    init(from apiResponse: [String: Any]) {
        self.id = apiResponse["reviewId"] as? String ?? apiResponse["id"] as? String ?? UUID().uuidString
        self.productId = apiResponse["productId"] as? String ?? ""
        self.slug = apiResponse["slug"] as? String ?? "string"
        self.reviewText = apiResponse["reviewText"] as? String ?? ""
        self.rating = apiResponse["rating"] as? Int ?? 0
        self.userName = apiResponse["userName"] as? String ?? "Anonymous"
        self.deleted = apiResponse["deleted"] as? Bool ?? false
        self.updatedAt = apiResponse["updatedAt"] as? String ?? ISO8601DateFormatter().string(from: Date())
        self.reviewId = apiResponse["reviewId"] as? String ?? apiResponse["id"] as? String ?? UUID().uuidString
    }
    
    init(
        id: String? = nil,
        productId: String,
        slug: String = "string",
        reviewText: String,
        rating: Int,
        userName: String,
        deleted: Bool = false,
        updatedAt: String? = nil,
        reviewId: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.productId = productId
        self.slug = slug
        self.reviewText = reviewText
        self.rating = rating
        self.userName = userName
        self.deleted = deleted
        self.updatedAt = updatedAt ?? ISO8601DateFormatter().string(from: Date())
        self.reviewId = reviewId ?? UUID().uuidString
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "productId": productId,
            "slug": slug,
            "reviewText": reviewText,
            "rating": rating,
            "userName": userName,
            "deleted": deleted,
            "updatedAt": updatedAt,
            "reviewId": reviewId
        ]
    }
}
