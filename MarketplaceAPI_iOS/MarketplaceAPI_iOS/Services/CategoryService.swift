import Foundation

class CategoryService {
    static let shared = CategoryService()
    
    private let baseURL = "https://marketplaceapi-storefrontapi-catalog.onrender.com"
    private let session = URLSession.shared
    
    private init() {}
    
    private func makeRequest(
        endpoint: String,
        method: String = "GET",
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
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
    
    func getCategories(completion: @escaping (Result<[String], Error>) -> Void) {
        makeRequest(endpoint: "/catalog/products/categories") { result in
            switch result {
            case .success(let data):
                do {
                    if let categoriesArray = try JSONSerialization.jsonObject(with: data) as? [String] {
                        completion(.success(categoriesArray))
                    } else {
                        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            completion(.failure(APIError(message: "Invalid JSON format", code: "INVALID_JSON", details: nil)))
                            return
                        }
                        
                        if let contentArray = jsonObject["content"] as? [String] {
                            completion(.success(contentArray))
                        } else {
                            completion(.failure(APIError(message: "No categories found in response", code: "NO_CATEGORIES", details: nil)))
                        }
                    }
                } catch {
                    completion(.failure(APIError(
                        message: "Failed to parse categories",
                        code: "PARSE_ERROR",
                        details: error.localizedDescription
                    )))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
