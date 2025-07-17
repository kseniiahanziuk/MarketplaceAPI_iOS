import Foundation

extension Review {
    var isValid: Bool {
        return !deleted && !reviewText.isEmpty && rating > 0 && rating <= 5
    }
    
    static func sortedByDate(_ reviews: [Review]) -> [Review] {
        return reviews.sorted { $0.updatedAtDate > $1.updatedAtDate }
    }
    
    static func filterByRating(_ reviews: [Review], rating: Int) -> [Review] {
        return reviews.filter { $0.rating == rating && $0.isValid }
    }
    
    static func filterByText(_ reviews: [Review], searchText: String) -> [Review] {
        return reviews.filter { review in
            review.isValid && (
                review.reviewText.localizedCaseInsensitiveContains(searchText) ||
                review.userName.localizedCaseInsensitiveContains(searchText)
            )
        }
    }
}
