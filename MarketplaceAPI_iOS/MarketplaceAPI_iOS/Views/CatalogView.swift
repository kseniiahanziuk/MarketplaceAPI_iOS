import SwiftUI

struct CatalogView: View {
    @Binding var productItems: [ProductItem]
    @Binding var showingCategories: Bool
    @State private var searchText = ""
    @State private var products = Product.sampleProducts
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                                showingCategories = true
                            }
                        })
                        {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                        }
                        
                        SearchBarView(text: $searchText)
                        
                        NavigationLink(destination: CartView(cartItems: $productItems)) {
                            ZStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.accentColor)
                                
                                if !productItems.isEmpty {
                                    Text("\(productItems.count)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .background(.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.top, 8)
                .background(Color(.systemBackground))
                    
                    
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 16) {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product, cartItems: $productItems)) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            if showingCategories {
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(width: 280)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 0)
                        
                        VStack {
                            CategoriesSliderView(showingCategories: $showingCategories)
                        }
                        .frame(width: 280)
                        .frame(maxHeight: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .offset(x: showingCategories ? 0 : -280)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: showingCategories)
                    
                    Spacer()
                }
                .background(
                    Color.black.opacity(showingCategories ? 0.3 : 0)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                                showingCategories = false
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: showingCategories)
                )
            }
        }
        .navigationBarHidden(true)
    }
}
