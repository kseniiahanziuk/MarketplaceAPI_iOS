import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "storefront")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Marketplace App")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                
                Group {
                    Text("About")
                        .font(.headline)
                    
                    Text("Welcome to our marketplace app! Discover amazing products from various vendors, enjoy seamless shopping experience, and get your favorite items delivered right to your doorstep.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Features")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "magnifyingglass", text: "Advanced product search")
                        FeatureRow(icon: "heart", text: "Wishlist and favorites")
                        FeatureRow(icon: "cart", text: "Easy shopping cart")
                        FeatureRow(icon: "truck.box", text: "Order tracking")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
    }
}
