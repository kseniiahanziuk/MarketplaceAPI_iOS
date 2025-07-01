import Foundation

struct ProductItem: Identifiable, Equatable {
    let id = UUID()
    let productId: String
    let name: String
    let price: Double
    var quantity: Int
    let image: String
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
    
    static func == (lhs: ProductItem, rhs: ProductItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.productId == rhs.productId &&
               lhs.name == rhs.name &&
               lhs.price == rhs.price &&
               lhs.quantity == rhs.quantity &&
               lhs.image == rhs.image
    }
    
    func toOrderItem() -> [String: Any] {
        return [
            "productId": productId,
            "quantity": quantity
        ]
    }
    
    func toOrderItemRequest() -> OrderItemRequest {
        return OrderItemRequest(
            productId: productId,
            quantity: quantity
        )
    }
    
    init(from product: Product, quantity: Int = 1) {
        self.productId = product.id
        self.name = product.name
        self.price = product.price
        self.quantity = quantity
        self.image = product.mainImage
    }
    
    init(productId: String, name: String, price: Double, quantity: Int, image: String) {
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.image = image
    }
}
