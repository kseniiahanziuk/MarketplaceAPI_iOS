import Foundation

struct ProductItem: Identifiable {
    let id = UUID()
    let productId: String
    let name: String
    let price: Double
    var quantity: Int
    let image: String
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
}
