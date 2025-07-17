import SwiftUI

struct StarRatingWithCount: View {
    let rating: Double
    let reviewCount: Int
    let starSize: CGFloat
    
    init(rating: Double, reviewCount: Int, starSize: CGFloat = 16) {
        self.rating = rating
        self.reviewCount = reviewCount
        self.starSize = starSize
    }
    
    var body: some View {
        HStack(spacing: 4) {
            StarRatingDisplay(rating: rating, starSize: starSize, showNumber: false)
            
            Text(String(format: "%.1f", rating))
                .font(.system(size: starSize))
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("(\(reviewCount))")
                .font(.system(size: starSize))
                .foregroundColor(.secondary)
        }
    }
}
