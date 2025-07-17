import Foundation
import SwiftUI

struct Order: Identifiable {
    let id: String
    let customerId: String
    let items: [ProductItem]
    let totalAmount: Double
    let status: OrderStatus
    let createdAt: Date
    let updatedAt: Date
    let shippingAddress: String
    
    init(from apiResponse: [String: Any]) {
        let normalizedResponse = normalizeOrderFields(apiResponse)
        
        if !validateOrderResponse(apiResponse) {
            print("Warning: Order response validation failed")
        }
        
        self.id = normalizedResponse["id"] as? String ?? ""
        self.customerId = normalizedResponse["customer_id"] as? String ?? normalizedResponse["customerId"] as? String ?? ""
        
        let apiItems = normalizedResponse["items"] as? [[String: Any]] ?? []
        self.items = apiItems.map { itemDict in
            ProductItem(
                productId: itemDict["product_id"] as? String ?? itemDict["productId"] as? String ?? "",
                name: "Product",
                price: 0.0,
                quantity: itemDict["quantity"] as? Int ?? 1,
                image: "photo"
            )
        }
        
        if let totalPrice = normalizedResponse["total_price"] as? Double {
            self.totalAmount = totalPrice
        } else if let totalAmount = normalizedResponse["totalAmount"] as? Double {
            self.totalAmount = totalAmount
        } else {
            self.totalAmount = 0.0
        }
        
        let statusString = normalizedResponse["status"] as? String ?? "PENDING"
        self.status = OrderStatus.fromAPIStatus(statusString)
        
        if let createdAtString = normalizedResponse["created_at"] as? String ?? normalizedResponse["createdAt"] as? String {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            self.createdAt = Date()
        }
        
        if let updatedAtString = normalizedResponse["updated_at"] as? String ?? normalizedResponse["updatedAt"] as? String {
            let formatter = ISO8601DateFormatter()
            self.updatedAt = formatter.date(from: updatedAtString) ?? Date()
        } else {
            self.updatedAt = Date()
        }
        
        self.shippingAddress = normalizedResponse["shippingAddress"] as? String ?? ""
    }
    
    init(id: String, customerId: String, items: [ProductItem], totalAmount: Double, status: OrderStatus, createdAt: Date, updatedAt: Date, shippingAddress: String) {
        self.id = id
        self.customerId = customerId
        self.items = items
        self.totalAmount = totalAmount
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.shippingAddress = shippingAddress
    }
    
    func toCreateOrderRequest() -> [String: Any] {
        return [
            "customer_id": customerId,
            "items": items.map { $0.toOrderItem() }
        ]
    }
}
