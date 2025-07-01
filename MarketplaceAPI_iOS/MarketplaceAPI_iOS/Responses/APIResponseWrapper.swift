import Foundation

struct APIResponseWrapper<T: Codable>: Codable {
    let data: T?
    let success: Bool
    let message: String?
    let error: APIError?
}
