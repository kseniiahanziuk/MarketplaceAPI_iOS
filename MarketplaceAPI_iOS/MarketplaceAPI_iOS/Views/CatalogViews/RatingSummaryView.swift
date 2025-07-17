import SwiftUI

struct RatingSummaryView: View {
    let ratingDistribution: [Int: Int]
    let totalReviews: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach([5, 4, 3, 2, 1], id: \.self) { stars in
                HStack {
                    Text("\(stars)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(
                                    width: geometry.size.width * percentage(for: stars),
                                    height: 6
                                )
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(ratingDistribution[stars] ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
    }
    
    private func percentage(for stars: Int) -> CGFloat {
        guard totalReviews > 0 else { return 0 }
        let count = ratingDistribution[stars] ?? 0
        return CGFloat(count) / CGFloat(totalReviews)
    }
}

