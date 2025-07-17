import Foundation
import SwiftUI

class ReviewController: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var allReviews: [Review] = []
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var reviewSubmitted = false
    
    @Published var currentPage = 0
    @Published var hasMoreReviews = true
    private let pageSize = 20
    
    private let apiService = ReviewService.shared
    
    func loadReviews(for productId: String) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getReviewsForProduct(productId: productId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedReviews):
                    self.reviews = Review.sortedByDate(fetchedReviews.filter { $0.isValid })
                    print("Loaded \(self.reviews.count) reviews for product \(productId)")
                    
                    AnalyticsManager.shared.logCustomEvent("reviews_loaded", parameters: [
                        "product_id": productId,
                        "review_count": self.reviews.count
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.reviews = []
                    AnalyticsManager.shared.logError(error, context: "load_reviews")
                }
            }
        }
    }
    
    func loadAllReviews(page: Int = 0, refresh: Bool = false) {
        guard !isLoading else { return }
        
        if refresh {
            allReviews = []
            currentPage = 0
            hasMoreReviews = true
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getAllReviews(page: page, size: pageSize) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedReviews):
                    let validReviews = fetchedReviews.filter { $0.isValid }
                    
                    if refresh {
                        self.allReviews = validReviews
                    } else {
                        self.allReviews.append(contentsOf: validReviews)
                    }
                    
                    self.currentPage = page
                    self.hasMoreReviews = fetchedReviews.count >= self.pageSize
                    
                    print("Loaded \(validReviews.count) reviews from database (page \(page))")
                    
                    AnalyticsManager.shared.logCustomEvent("all_reviews_loaded", parameters: [
                        "page": page,
                        "review_count": validReviews.count,
                        "total_reviews": self.allReviews.count
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_all_reviews")
                }
            }
        }
    }
    
    func loadMoreReviews() {
        guard hasMoreReviews && !isLoading else { return }
        loadAllReviews(page: currentPage + 1, refresh: false)
    }
    
    func submitReview(
        productId: String,
        reviewText: String,
        rating: Int,
        userName: String
    ) {
        guard !isSubmitting else { return }
        
        isSubmitting = true
        errorMessage = ""
        reviewSubmitted = false
        
        apiService.createReview(
            productId: productId,
            reviewText: reviewText,
            rating: rating,
            userName: userName
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                switch result {
                case .success(let newReview):
                    if newReview.isValid {
                        self.reviews.insert(newReview, at: 0)
                        self.reviewSubmitted = true
                        
                        AnalyticsManager.shared.logCustomEvent("review_submitted", parameters: [
                            "product_id": productId,
                            "rating": rating,
                            "review_length": reviewText.count
                        ])
                        
                        print("Review submitted successfully: \(newReview.id)")
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Failed to submit review: \(error.localizedDescription)"
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "submit_review")
                    print("Review submission failed: \(error)")
                }
            }
        }
    }
    
    func refreshReviews(for productId: String) {
        reviews = []
        loadReviews(for: productId)
    }
    
    func refreshAllReviews() {
        loadAllReviews(page: 0, refresh: true)
    }
    
    func averageRating() -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }
    
    func ratingDistribution() -> [Int: Int] {
        var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        for review in reviews {
            distribution[review.rating, default: 0] += 1
        }
        return distribution
    }
    
    func searchReviews(searchText: String) {
        guard !searchText.isEmpty else {
            refreshAllReviews()
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.searchReviews(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let searchResults):
                    self.allReviews = Review.sortedByDate(searchResults)
                    print("Search returned \(searchResults.count) reviews")
                    
                    AnalyticsManager.shared.logCustomEvent("reviews_searched", parameters: [
                        "search_term": searchText,
                        "result_count": searchResults.count
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "search_reviews")
                }
            }
        }
    }
    
    func filterReviewsByRating(_ rating: Int) {
        if rating == 0 {
            refreshAllReviews()
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getReviewsByRating(rating: rating) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let filteredReviews):
                    self.allReviews = Review.sortedByDate(filteredReviews)
                    print("Filter returned \(filteredReviews.count) reviews with rating \(rating)")
                    
                    AnalyticsManager.shared.logCustomEvent("reviews_filtered", parameters: [
                        "filter_rating": rating,
                        "result_count": filteredReviews.count
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "filter_reviews")
                }
            }
        }
    }
    
    func loadRecentReviews(limit: Int = 10) {
        isLoading = true
        errorMessage = ""
        
        apiService.getRecentReviews(limit: limit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let recentReviews):
                    self.allReviews = recentReviews
                    print("Loaded \(recentReviews.count) recent reviews")
                    
                    AnalyticsManager.shared.logCustomEvent("recent_reviews_loaded", parameters: [
                        "limit": limit,
                        "result_count": recentReviews.count
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_recent_reviews")
                }
            }
        }
    }
    
    func getReviewsStatistics() -> (total: Int, averageRating: Double, ratingDistribution: [Int: Int]) {
        let total = reviews.count
        let average = averageRating()
        let distribution = ratingDistribution()
        
        return (total: total, averageRating: average, ratingDistribution: distribution)
    }
}
