import Foundation

struct APIError: Codable, Error, LocalizedError {
    let message: String
    let code: String?
    let details: String?
    
    var errorDescription: String? {
        return message
    }
}
