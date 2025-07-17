import SwiftUI

struct StarRatingInput: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    let starSize: CGFloat
    
    init(rating: Binding<Int>, starSize: CGFloat = 30) {
        self._rating = rating
        self.starSize = starSize
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    rating = index
                }) {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .font(.system(size: starSize))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
