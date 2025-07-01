import Foundation

struct CreateOrderRequest: Codable {
    let customerId: String
    let items: [OrderItemRequest]
}
