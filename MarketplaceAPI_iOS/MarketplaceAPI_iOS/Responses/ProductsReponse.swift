import Foundation

struct ProductsResponse: Codable {
    let products: [ProductDTO]
    let totalElements: Int?
    let totalPages: Int?
    let currentPage: Int?
    let size: Int?
}
