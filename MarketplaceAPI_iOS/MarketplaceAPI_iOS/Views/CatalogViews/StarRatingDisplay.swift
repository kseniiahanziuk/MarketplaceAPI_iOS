import SwiftUI

struct StarRatingDisplay: View {
    let rating: Double
    let maxRating: Int = 5
    let starSize: CGFloat
    let showNumber: Bool
    
    init(rating: Double, starSize: CGFloat = 16, showNumber: Bool = true) {
        self.rating = rating
        self.starSize = starSize
        self.showNumber = showNumber
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .foregroundColor(.yellow)
                    .font(.system(size: starSize))
            }
            
            if showNumber {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: starSize))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        let difference = rating - Double(index - 1)
        
        if difference >= 1.0 {
            return "star.fill"
        } else if difference >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
