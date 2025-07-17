import SwiftUI

struct ReviewsSectionView: View {
    let product: Product
    @StateObject private var reviewController = ReviewController()
    @State private var showingAddReview = false
    @State private var showingAllReviews = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                
                Spacer()
                
                if !reviewController.reviews.isEmpty {
                    Button("See all") {
                        showingAllReviews = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                }
            }
            
            if reviewController.isLoading {
                loadingView
            } else if reviewController.reviews.isEmpty {
                emptyReviewsView
            } else {
                reviewsContentView
            }
            
            addReviewButton
        }
        .onAppear {
            reviewController.loadReviews(for: product.id)
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(
                product: product,
                isPresented: $showingAddReview,
                reviewController: reviewController
            )
        }
        .sheet(isPresented: $showingAllReviews) {
            AllReviewsView(
                product: product,
                reviewController: reviewController
            )
        }
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading reviews...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 20)
    }
    
    private var emptyReviewsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No reviews yet")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("Be the first to review this product!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 20)
    }
    
    private var reviewsContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ratingSummaryView
            
            ForEach(Array(reviewController.reviews.prefix(2)), id: \.id) { review in
                ReviewCardView(review: review)
            }
        }
    }
    
    private var ratingSummaryView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    StarRatingDisplay(
                        rating: reviewController.averageRating(),
                        starSize: 20,
                        showNumber: false
                    )
                    
                    Text(String(format: "%.1f", reviewController.averageRating()))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Text("\(reviewController.reviews.count) review\(reviewController.reviews.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private var addReviewButton: some View {
        Button(action: {
            showingAddReview = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Write a review")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
