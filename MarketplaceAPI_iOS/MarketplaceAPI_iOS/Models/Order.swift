import Foundation
import SwiftUI

struct Order: Identifiable {
    let id: String
    let customerId: String
    let items: [ProductItem]
    let totalAmount: Double
    let status: OrderStatus
    let createdAt: Date
    let shippingAddress: String
    
    init(from apiResponse: [String: Any]) {
        self.id = apiResponse["id"] as? String ?? ""
        self.customerId = apiResponse["customerId"] as? String ?? ""
        
        let apiItems = apiResponse["items"] as? [[String: Any]] ?? []
        self.items = apiItems.map { itemDict in
            ProductItem(
                productId: itemDict["productId"] as? String ?? "",
                name: "Product",
                price: 0.0,
                quantity: itemDict["quantity"] as? Int ?? 1,
                image: "photo"
            )
        }
        
        self.totalAmount = apiResponse["totalAmount"] as? Double ?? 0.0
        
        let statusString = apiResponse["status"] as? String ?? "pending"
        self.status = OrderStatus(rawValue: statusString) ?? .pending
        
        if let createdAtString = apiResponse["createdAt"] as? String {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            self.createdAt = Date()
        }
        
        self.shippingAddress = apiResponse["shippingAddress"] as? String ?? ""
    }
    
    init(id: String, customerId: String, items: [ProductItem], totalAmount: Double, status: OrderStatus, createdAt: Date, shippingAddress: String) {
        self.id = id
        self.customerId = customerId
        self.items = items
        self.totalAmount = totalAmount
        self.status = status
        self.createdAt = createdAt
        self.shippingAddress = shippingAddress
    }
    
    func toCreateOrderRequest() -> [String: Any] {
        return [
            "customerId": customerId,
            "items": items.map { $0.toOrderItem() }
        ]
    }
    
    func toUpdateOrderRequest() -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        return [
            "customerId": customerId,
            "items": items.map { $0.toOrderItem() },
            "status": status.rawValue,
            "shippingAddress": shippingAddress
        ]
    }
    
    func toStatusUpdateRequest() -> [String: Any] {
        return [
            "status": status.rawValue
        ]
    }
}

enum OrderStatus: String {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .yellow
        case .shipped: return .blue
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    static func fromAPIStatus(_ apiStatus: String) -> OrderStatus {
        return OrderStatus(rawValue: apiStatus.lowercased()) ?? .pending
    }
    
    var apiStatus: String {
        return self.rawValue.uppercased()
    }
}
