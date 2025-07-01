import Foundation

class CatalogService {
    static let shared = CatalogService()
    
    private let baseURL = "https://marketplaceapi-storefrontapi-catalog.onrender.com"
    private let session = URLSession.shared
    
    private init() {}
    
    private func makeRequest(
        endpoint: String,
        method: String = "GET",
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
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError(message: "Invalid response", code: "INVALID_RESPONSE", details: nil)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError(message: "No data received", code: "NO_DATA", details: nil)))
                    return
                }
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completion(.success(data))
                } else {
                    completion(.failure(APIError(
                        message: "HTTP Error \(httpResponse.statusCode)",
                        code: "HTTP_ERROR",
                        details: String(data: data, encoding: .utf8)
                    )))
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
        
        makeRequest(endpoint: "/catalog/products", queryParams: queryParams) { result in
            switch result {
            case .success(let data):
                do {
                    guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        completion(.failure(APIError(message: "Invalid JSON format", code: "INVALID_JSON", details: nil)))
                        return
                    }
                    
                    if let contentArray = jsonObject["content"] as? [[String: Any]] {
                        let products = contentArray.map { Product(from: $0) }
                        completion(.success(products))
                    } else if let productsArray = jsonObject["products"] as? [[String: Any]] {
                        let products = productsArray.map { Product(from: $0) }
                        completion(.success(products))
                    } else {
                        completion(.failure(APIError(message: "No products found in response", code: "NO_PRODUCTS", details: nil)))
                    }
                } catch {
                    completion(.failure(APIError(
                        message: "Failed to parse products",
                        code: "PARSE_ERROR",
                        details: error.localizedDescription
                    )))
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
                    completion(.failure(APIError(
                        message: "Failed to parse product",
                        code: "PARSE_ERROR",
                        details: error.localizedDescription
                    )))
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
}
