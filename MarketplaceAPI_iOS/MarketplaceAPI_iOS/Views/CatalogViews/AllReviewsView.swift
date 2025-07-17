import SwiftUI

struct AllReviewsView: View {
    let product: Product
    @ObservedObject var reviewController: ReviewController
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddReview = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if reviewController.reviews.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 16) {
                        ratingOverviewSection
                        
                        Divider()
                        
                        reviewsListSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add review") {
                        showingAddReview = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(
                product: product,
                isPresented: $showingAddReview,
                reviewController: reviewController
            )
        }
        .refreshable {
            reviewController.refreshReviews(for: product.id)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No reviews yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to share your thoughts about this product!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Write first review") {
                showingAddReview = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var ratingOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Text(String(format: "%.1f", reviewController.averageRating()))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading) {
                            StarRatingDisplay(
                                rating: reviewController.averageRating(),
                                starSize: 20,
                                showNumber: false
                            )
                            
                            Text("\(reviewController.reviews.count) review\(reviewController.reviews.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    RatingSummaryView(
                        ratingDistribution: reviewController.ratingDistribution(),
                        totalReviews: reviewController.reviews.count
                    )
                }
                .frame(width: 120)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private var reviewsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(reviewController.reviews, id: \.id) { review in
                    ReviewCardView(review: review)
                }
            }
        }
    }
}

