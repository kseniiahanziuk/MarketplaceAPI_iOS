import Foundation

class ReviewService {
    static let shared = ReviewService()
    
    private let baseURL = "https://marketplaceapi-storefrontapi-catalog.onrender.com"
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
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
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
        
        session.dataTask(with: request) { data, response, error in
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
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "No data received", code: "NO_DATA", details: nil)))
                }
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            
            DispatchQueue.main.async {
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
    
    func getReviewsForProduct(
        productId: String,
        completion: @escaping (Result<[Review], Error>) -> Void
    ) {
        print("Getting reviews for product: \(productId)")
        
        makeRequest(endpoint: "/reviews/id/\(productId)") { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let reviews = jsonArray.compactMap { reviewDict -> Review? in
                            let review = Review(from: reviewDict)
                            return review.deleted ? nil : review
                        }
                        print("Loaded \(reviews.count) reviews from array")
                        completion(.success(reviews))
                        
                    } else if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let review = Review(from: jsonObject)
                        let reviews = review.deleted ? [] : [review]
                        print("Loaded single review")
                        completion(.success(reviews))
                        
                    } else {
                        print("No reviews found or invalid format")
                        completion(.success([]))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(
                        message: "Failed to parse reviews",
                        code: "PARSE_ERROR",
                        details: error.localizedDescription
                    )))
                }
                
            case .failure(let error):
                print("Failed to get reviews: \(error)")
                if let apiError = error as? APIError,
                   apiError.code == "HTTP_ERROR",
                   apiError.message.contains("404") {
                    print("No reviews found for product \(productId)")
                    completion(.success([]))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createReview(
        productId: String,
        reviewText: String,
        rating: Int,
        userName: String,
        completion: @escaping (Result<Review, Error>) -> Void
    ) {
        let requestBody: [String: Any] = [
            "productId": productId,
            "slug": "string",
            "reviewText": reviewText,
            "rating": rating,
            "userName": userName,
            "deleted": false,
            "updatedAt": ISO8601DateFormatter().string(from: Date()),
            "reviewId": UUID().uuidString
        ]
        
        makeRequest(
            endpoint: "/reviews",
            method: "POST",
            body: requestBody
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let review = Review(from: jsonObject)
                        print("Review created successfully: \(review.id)")
                        completion(.success(review))
                    } else {
                        print("Invalid review format in response")
                        completion(.failure(APIError(message: "Invalid review format", code: "INVALID_FORMAT", details: nil)))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(APIError(message: "Failed to parse review", code: "PARSE_ERROR", details: error.localizedDescription)))
                }
            case .failure(let error):
                print("Review creation failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getAllReviews(
        page: Int = 0,
        size: Int = 20,
        completion: @escaping (Result<[Review], Error>) -> Void
    ) {
        print("Getting all reviews from database")
        
        var urlComponents = URLComponents(string: "\(baseURL)/reviews")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(APIError(message: "Invalid URL", code: "INVALID_URL", details: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "Invalid response", code: "INVALID_RESPONSE", details: nil)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError(message: "No data received", code: "NO_DATA", details: nil)))
                }
                return
            }
            
            DispatchQueue.main.async {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                            let reviews = jsonArray.compactMap { reviewDict -> Review? in
                                let review = Review(from: reviewDict)
                                return review.deleted ? nil : review
                            }
                            print("Loaded \(reviews.count) reviews from database")
                            completion(.success(reviews))
                        } else if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let content = jsonObject["content"] as? [[String: Any]] {
                                let reviews = content.compactMap { reviewDict -> Review? in
                                    let review = Review(from: reviewDict)
                                    return review.deleted ? nil : review
                                }
                                print("Loaded \(reviews.count) reviews from paginated response")
                                completion(.success(reviews))
                            } else {
                                completion(.success([]))
                            }
                        } else {
                            completion(.success([]))
                        }
                    } catch {
                        completion(.failure(APIError(message: "Failed to parse reviews", code: "PARSE_ERROR", details: error.localizedDescription)))
                    }
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
    
    func getReviewsByRating(
        rating: Int,
        completion: @escaping (Result<[Review], Error>) -> Void
    ) {
        getAllReviews { result in
            switch result {
            case .success(let reviews):
                let filteredReviews = reviews.filter { $0.rating == rating }
                completion(.success(filteredReviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRecentReviews(
        limit: Int = 10,
        completion: @escaping (Result<[Review], Error>) -> Void
    ) {
        getAllReviews(page: 0, size: limit) { result in
            switch result {
            case .success(let reviews):
                let sortedReviews = reviews.sorted { review1, review2 in
                    let formatter = ISO8601DateFormatter()
                    let date1 = formatter.date(from: review1.updatedAt) ?? Date.distantPast
                    let date2 = formatter.date(from: review2.updatedAt) ?? Date.distantPast
                    return date1 > date2
                }
                let limitedReviews = Array(sortedReviews.prefix(limit))
                completion(.success(limitedReviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchReviews(
        searchText: String,
        completion: @escaping (Result<[Review], Error>) -> Void
    ) {
        getAllReviews { result in
            switch result {
            case .success(let reviews):
                let filteredReviews = reviews.filter { review in
                    review.reviewText.localizedCaseInsensitiveContains(searchText) ||
                    review.userName.localizedCaseInsensitiveContains(searchText)
                }
                completion(.success(filteredReviews))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
