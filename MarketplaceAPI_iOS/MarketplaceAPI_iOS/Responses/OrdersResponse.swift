import Foundation

struct OrdersResponse: Codable {
    let orders: [OrderDTO]
    let totalElements: Int?
    let totalPages: Int?
    let currentPage: Int?
    let size: Int?
}
