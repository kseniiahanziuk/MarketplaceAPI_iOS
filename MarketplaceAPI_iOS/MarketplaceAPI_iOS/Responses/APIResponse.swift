import Foundation

struct APIResponse<T> {
    let data: T?
    let success: Bool
    let message: String?
    
    init(data: T?, success: Bool = true, message: String? = nil) {
        self.data = data
        self.success = success
        self.message = message
    }
}
