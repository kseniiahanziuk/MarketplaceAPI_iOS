import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Binding var cartItems: [ProductItem]
    
    var body: some View {
        VStack {
            Text(product.name)
        }
        .navigationTitle("Product detail")
    }
}
