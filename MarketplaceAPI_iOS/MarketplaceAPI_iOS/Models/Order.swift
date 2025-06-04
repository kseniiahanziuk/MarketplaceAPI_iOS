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
}
