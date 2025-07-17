import SwiftUI

struct ReviewCardView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(review.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StarRatingDisplay(
                        rating: Double(review.rating),
                        starSize: 18,
                        showNumber: false
                    )
                    
                    Text("\(review.rating) star\(review.rating == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !review.reviewText.isEmpty {
                Text(review.reviewText)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

