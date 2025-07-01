import Foundation

struct OrderDTO: Codable {
    let id: String
    let customerId: String
    let items: [OrderItemDTO]
    let totalAmount: Double
    let status: String
    let createdAt: String
    let shippingAddress: String?
    
    func toDomainModel() -> Order {
        let orderItems = items.map { item in
            ProductItem(
                productId: item.productId,
                name: "Product",
                price: 0.0,
                quantity: item.quantity,
                image: "photo"
            )
        }
        
        let orderStatus = OrderStatus(rawValue: status) ?? .pending
        
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: createdAt) ?? Date()
        
        return Order(
            id: id,
            customerId: customerId,
            items: orderItems,
            totalAmount: totalAmount,
            status: orderStatus,
            createdAt: createdDate,
            shippingAddress: shippingAddress ?? ""
        )
    }
}
