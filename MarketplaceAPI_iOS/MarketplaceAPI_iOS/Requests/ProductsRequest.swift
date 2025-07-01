import Foundation

struct ProductsRequest {
    let page: Int
    let size: Int
    let searchTerm: String?
    let filter: ProductFilter
    
    func toQueryParams() -> [String: String] {
        return filter.toAPIQueryParams(page: page, size: size, searchTerm: searchTerm)
    }
}
