import SwiftUI

struct AddReviewView: View {
    let product: Product
    @Binding var isPresented: Bool
    @ObservedObject var reviewController: ReviewController
    
    @State private var rating: Int = 5
    @State private var reviewText: String = ""
    @State private var userName: String = ""
    @AppStorage("userEmail") private var userEmail = "user@gmail.com"
    @AppStorage("userName") private var savedUserName = "User"
    
    private var isValidReview: Bool {
        !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        rating > 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    productInfoSection
                    ratingSection
                    reviewTextSection
                    userNameSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Write a review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        submitReview()
                    }
                    .disabled(!isValidReview || reviewController.isSubmitting)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            userName = savedUserName
        }
        .alert("Review submitted", isPresented: $reviewController.reviewSubmitted) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Thank you for your review!")
        }
        .alert("Error", isPresented: $reviewController.showError) {
            Button("OK") {
                reviewController.showError = false
            }
        } message: {
            Text(reviewController.errorMessage)
        }
    }
    
    private var productInfoSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(width: 60, height: 60)
                
                Image(systemName: product.mainImage)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.brand)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating")
                .font(.headline)
            
            Text("How would you rate this product?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                StarRatingInput(rating: $rating, starSize: 40)
                
                Spacer()
                
                Text(ratingDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: rating)
            }
        }
    }
    
    private var reviewTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.headline)
            
            Text("Share your thoughts about this product")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
                    .frame(minHeight: 120)
                
                if reviewText.isEmpty {
                    Text("Write your review here...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $reviewText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
            }
            
            HStack {
                Spacer()
                Text("\(reviewText.count)/500")
                    .font(.caption)
                    .foregroundColor(reviewText.count > 500 ? .red : .secondary)
            }
        }
    }
    
    private var userNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name")
                .font(.headline)
            
            TextField("Your name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: userName) { oldValue, newValue in
                    savedUserName = newValue
                }
        }
    }
    
    private var ratingDescription: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very good"
        case 5: return "Excellent"
        default: return ""
        }
    }
    
    private func submitReview() {
        let trimmedReviewText = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUserName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedReviewText.count <= 500 else {
            reviewController.errorMessage = "Review text must be 500 characters or less"
            reviewController.showError = true
            return
        }
        
        reviewController.submitReview(
            productId: product.id,
            reviewText: trimmedReviewText,
            rating: rating,
            userName: trimmedUserName
        )
    }
}
