import SwiftUI

struct CategoriesSliderView: View {
    // needs proper implementation with filters and allignment of the categories.
    @Binding var showingCategories: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        showingCategories = false
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }

                Text("Categories")
                    .font(.headline)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 82)

            Divider()

            Spacer()
        }
        .navigationTitle("Categories")
    }
}
