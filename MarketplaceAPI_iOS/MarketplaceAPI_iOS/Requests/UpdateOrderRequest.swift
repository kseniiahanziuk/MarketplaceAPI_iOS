import Foundation

struct UpdateOrderRequest: Codable {
    let customerId: String
    let items: [OrderItemRequest]
    let status: String
    let shippingAddress: String
}
