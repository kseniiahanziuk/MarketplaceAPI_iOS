import Foundation

func parseProductsFromAPI(_ response: [String: Any]) -> [Product] {
    guard let productsArray = response["products"] as? [[String: Any]] else {
        return []
    }
    
    return productsArray.map { Product(from: $0) }
}

func parseOrdersFromAPI(_ response: [String: Any]) -> [Order] {
    if let ordersArray = response["orders"] as? [[String: Any]] {
        return ordersArray.map { Order(from: $0) }
    } else if let contentArray = response["content"] as? [[String: Any]] {
        return contentArray.map { Order(from: $0) }
    } else {
        return []
    }
}

func createOrderRequestFromCart(customerId: String, cartItems: [ProductItem]) -> [String: Any] {
    var orderRequest: [String: Any] = [:]
    
    orderRequest["customer_id"] = customerId
    orderRequest["items"] = cartItems.map { item in
        return [
            "product_id": item.productId,
            "quantity": item.quantity
        ]
    }
    
    let totalAmount = cartItems.reduce(0.0) { total, item in
        return total + (item.price * Double(item.quantity))
    }
    
    orderRequest["total_price"] = totalAmount
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: orderRequest, options: .prettyPrinted),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print("Order request body:")
        print(jsonString)
    }
    
    return orderRequest
}

func validateOrderResponse(_ response: [String: Any]) -> Bool {
    guard let id = response["id"] as? String, !id.isEmpty else {
        print("Order response missing or empty ID")
        return false
    }
    
    guard let customerId = response["customer_id"] as? String ?? response["customerId"] as? String,
          !customerId.isEmpty else {
        print("Order response missing or empty customer_id")
        return false
    }
    
    guard let items = response["items"] as? [[String: Any]], !items.isEmpty else {
        print("Order response missing or empty items array")
        return false
    }
    
    guard let status = response["status"] as? String, !status.isEmpty else {
        print("Order response missing or empty status")
        return false
    }
    
    return true
}

func normalizeOrderFields(_ response: [String: Any]) -> [String: Any] {
    var normalized = response
    
    if let customerId = response["customer_id"] as? String {
        normalized["customerId"] = customerId
    }
    
    if let totalPrice = response["total_price"] as? Double {
        normalized["totalAmount"] = totalPrice
    }
    
    if let createdAt = response["created_at"] as? String {
        normalized["createdAt"] = createdAt
    }
    
    if let updatedAt = response["updated_at"] as? String {
        normalized["updatedAt"] = updatedAt
    }
    
    if let items = response["items"] as? [[String: Any]] {
        let normalizedItems = items.map { item -> [String: Any] in
            var normalizedItem = item
            if let productId = item["product_id"] as? String {
                normalizedItem["productId"] = productId
            }
            return normalizedItem
        }
        normalized["items"] = normalizedItems
    }
    
    return normalized
}
