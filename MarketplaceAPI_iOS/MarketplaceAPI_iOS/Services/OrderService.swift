import Foundation

class OrderService {
    static let shared = OrderService()
    
    private let baseURL = "https://marketplaceapi-storefront-orders.onrender.com"
    private let session = URLSession.shared
    
    private init() {}
    
    private func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        queryParams: [String: String] = [:],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")!
        if !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(APIError(message: "Invalid URL", code: "INVALID_URL", details: nil)))
            return
        }
        
        print("Making request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                print("Request body: \(body)")
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError(message: "Invalid response", code: "INVALID_RESPONSE", details: nil)))
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    completion(.failure(APIError(message: "No data received", code: "NO_DATA", details: nil)))
                    return
                }
                
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Response data: \(dataString.prefix(500))")
                }
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completion(.success(data))
                } else {
                    do {
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                        completion(.failure(errorResponse.error))
                    } catch {
                        completion(.failure(APIError(
                            message: "HTTP Error \(httpResponse.statusCode)",
                            code: "HTTP_ERROR",
                            details: String(data: data, encoding: .utf8)
                        )))
                    }
                }
            }
        }.resume()
    }
    
    func getProducts(
        filter: ProductFilter = ProductFilter(),
        page: Int = 0,
        size: Int = 20,
        searchTerm: String? = nil,
        completion: @escaping (Result<[Product], Error>) -> Void
    ) {
        let queryParams = filter.toAPIQueryParams(page: page, size: size, searchTerm: searchTerm)
        
        makeRequest(
            endpoint: "/catalog/products",
            queryParams: queryParams
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let products = parseProductsFromAPI(jsonObject)
                        completion(.success(products))
                    } else if let productsArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let products = productsArray.map { Product(from: $0) }
                        completion(.success(products))
                    } else {
                        completion(.failure(APIError(message: "Invalid response format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse products", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getProduct(id: String, completion: @escaping (Result<Product, Error>) -> Void) {
        makeRequest(endpoint: "/catalog/products/\(id)") { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let product = Product(from: jsonObject)
                        completion(.success(product))
                    } else {
                        completion(.failure(APIError(message: "Invalid product format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse product", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchProducts(
        searchTerm: String,
        page: Int = 0,
        size: Int = 20,
        completion: @escaping (Result<[Product], Error>) -> Void
    ) {
        let filter = ProductFilter()
        getProducts(filter: filter, page: page, size: size, searchTerm: searchTerm, completion: completion)
    }
    
    func createOrder(
        customerId: String,
        cartItems: [ProductItem],
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        let requestBody = createOrderRequestFromCart(customerId: customerId, cartItems: cartItems)
        
        makeRequest(
            endpoint: "/orders",
            method: "POST",
            body: requestBody
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let order = Order(from: jsonObject)
                        completion(.success(order))
                    } else {
                        completion(.failure(APIError(message: "Invalid order format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse order", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getOrders(
        page: Int = 0,
        size: Int = 20,
        status: OrderStatus? = nil,
        customerId: String? = nil,
        completion: @escaping (Result<[Order], Error>) -> Void
    ) {
        var queryParams: [String: String] = [
            "page": String(page),
            "size": String(size),
            "sortField": "createdAt",
            "direction": "DESC"
        ]
        
        if let status = status {
            queryParams["filter[status]"] = status.rawValue
        }
        if let customerId = customerId {
            queryParams["filter[customerId]"] = customerId
        }
        
        makeRequest(
            endpoint: "/orders",
            queryParams: queryParams
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let orders = parseOrdersFromAPI(jsonObject)
                        completion(.success(orders))
                    } else if let ordersArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let orders = ordersArray.map { Order(from: $0) }
                        completion(.success(orders))
                    } else {
                        completion(.failure(APIError(message: "Invalid orders format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse orders", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getOrder(id: String, completion: @escaping (Result<Order, Error>) -> Void) {
        makeRequest(endpoint: "/orders/\(id)") { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let order = Order(from: jsonObject)
                        completion(.success(order))
                    } else {
                        completion(.failure(APIError(message: "Invalid order format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse order", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateOrder(
        order: Order,
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        let requestBody = order.toUpdateOrderRequest()
        
        makeRequest(
            endpoint: "/orders/\(order.id)",
            method: "PUT",
            body: requestBody
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let updatedOrder = Order(from: jsonObject)
                        completion(.success(updatedOrder))
                    } else {
                        completion(.failure(APIError(message: "Invalid order format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse updated order", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateOrderStatus(
        orderId: String,
        newStatus: OrderStatus,
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        let requestBody = ["status": newStatus.rawValue]
        
        makeRequest(
            endpoint: "/orders/\(orderId)",
            method: "PATCH",
            body: requestBody
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let updatedOrder = Order(from: jsonObject)
                        completion(.success(updatedOrder))
                    } else {
                        completion(.failure(APIError(message: "Invalid order format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse updated order", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteOrder(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/orders/\(id)", method: "DELETE") { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getOrderStatus(id: String, completion: @escaping (Result<OrderStatus, Error>) -> Void) {
        makeRequest(endpoint: "/orders/\(id)/status") { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let statusString = jsonObject["status"] as? String {
                        let orderStatus = OrderStatus(rawValue: statusString) ?? .pending
                        completion(.success(orderStatus))
                    } else {
                        completion(.failure(APIError(message: "Invalid status format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse status", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
