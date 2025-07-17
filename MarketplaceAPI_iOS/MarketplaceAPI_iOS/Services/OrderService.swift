import Foundation

class OrderService {
    static let shared = OrderService()
    
    private let baseURL = "https://marketplaceapi-storefront-orders.onrender.com"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
    }
    
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
        
        print("Making \(method) request to: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Request body:")
                    print(jsonString)
                }
            } catch {
                print("Failed to serialize request body: \(error)")
                completion(.failure(error))
                return
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            print("Response received")
            
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "Invalid response", code: "INVALID_RESPONSE", details: nil)))
                }
                return
            }
            
            print("HTTP status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "No data received", code: "NO_DATA", details: nil)))
                }
                return
            }
            
            print("Response data size: \(data.count) bytes")
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response data:")
                print(dataString)
            }
            
            DispatchQueue.main.async {
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
        }
        
        print("Starting network task")
        task.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            print("30 second timeout check")
            if task.state == .running {
                print("Request still running after 30 seconds - potential timeout")
                task.cancel()
            }
        }
    }
    
    func createOrder(
        customerId: String,
        cartItems: [ProductItem],
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        print("Creating order for customer: \(customerId)")
        print("Cart items count: \(cartItems.count)")
        
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
                        print("Order created successfully: \(order.id)")
                        completion(.success(order))
                    } else {
                        print("Invalid order format in response")
                        completion(.failure(APIError(message: "Invalid order format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse order", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                print("Order creation failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getOrderStatus(id: String, completion: @escaping (Result<OrderStatus, Error>) -> Void) {
        print("Getting status for order: \(id)")
        
        makeRequest(endpoint: "/orders/\(id)/status") { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let statusString = jsonObject["status"] as? String {
                        let orderStatus = OrderStatus.fromAPIStatus(statusString)
                        print("Order status retrieved: \(orderStatus.rawValue)")
                        completion(.success(orderStatus))
                    } else {
                        print("Invalid status format in response")
                        completion(.failure(APIError(message: "Invalid status format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse status", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                print("Failed to get order status: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getOrders(
        page: Int = 0,
        size: Int = 20,
        status: OrderStatus? = nil,
        customerId: String,
        completion: @escaping (Result<[Order], Error>) -> Void
    ) {
        guard !customerId.isEmpty else {
            completion(.failure(APIError(message: "Customer ID is required", code: "MISSING_CUSTOMER_ID", details: nil)))
            return
        }
        
        var queryParams: [String: String] = [
            "customerId": customerId,
            "page": String(page),
            "size": String(size),
            "sortField": "createdAt",
            "direction": "DESC"
        ]
        
        if let status = status {
            queryParams["filter[status]"] = status.rawValue
        }
        
        print("Loading orders with params: \(queryParams)")
        
        makeRequest(
            endpoint: "/orders",
            queryParams: queryParams
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let orders = parseOrdersFromAPI(jsonObject)
                        print("Successfully parsed \(orders.count) orders")
                        completion(.success(orders))
                    } else if let ordersArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let orders = ordersArray.map { Order(from: $0) }
                        print("Successfully parsed \(orders.count) orders from array")
                        completion(.success(orders))
                    } else {
                        print("Invalid orders format in response")
                        completion(.failure(APIError(message: "Invalid orders format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse orders", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                print("Failed to load orders: \(error)")
                completion(.failure(error))
            }
        }
    }
}
