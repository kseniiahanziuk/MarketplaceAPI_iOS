import Foundation

func parseProductsFromAPI(_ response: [String: Any]) -> [Product] {
    guard let productsArray = response["products"] as? [[String: Any]] else {
        return []
    }
    
    return productsArray.map { Product(from: $0) }
}

func parseOrdersFromAPI(_ response: [String: Any]) -> [Order] {
    guard let ordersArray = response["orders"] as? [[String: Any]] else {
        return []
    }
    
    return ordersArray.map { Order(from: $0) }
}

func createOrderRequestFromCart(customerId: String, cartItems: [ProductItem]) -> [String: Any] {
    return [
        "customerId": customerId,
        "items": cartItems.map { $0.toOrderItem() }
    ]
}
