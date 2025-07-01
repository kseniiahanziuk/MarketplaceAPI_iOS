import Foundation

struct OrderItemRequest: Codable {
    let productId: String
    let quantity: Int
}
