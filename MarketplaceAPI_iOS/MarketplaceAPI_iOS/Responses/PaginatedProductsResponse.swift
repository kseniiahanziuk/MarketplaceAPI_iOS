import Foundation

struct PaginatedProductsResponse {
    let products: [Product]
    let totalPages: Int?
    let totalElements: Int?
    let currentPage: Int?
    let size: Int?
    let hasMore: Bool
}
