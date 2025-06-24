import SwiftUI

struct CatalogView: View {
    @Binding var productItems: [ProductItem]
    @Binding var likedProducts: [Product]
    @Binding var showingCategories: Bool
    @Binding var productFilter: ProductFilter
    @State private var searchText = ""
    @State private var products = Product.sampleProducts
    @FocusState private var isSearchFocused: Bool
    
    var filteredProducts: [Product] {
        var filtered = products
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if !productFilter.selectedCategories.isEmpty && !productFilter.selectedCategories.contains("All") {
            filtered = filtered.filter { productFilter.selectedCategories.contains($0.category) }
        }
        
        if !productFilter.selectedBrands.isEmpty {
            filtered = filtered.filter { productFilter.selectedBrands.contains($0.brand) }
        }
        
        if !productFilter.selectedColors.isEmpty {
            filtered = filtered.filter { productFilter.selectedColors.contains($0.color) }
        }
        
        filtered = filtered.filter {
            $0.price >= productFilter.priceRange.lowerBound &&
            $0.price <= productFilter.priceRange.upperBound
        }
        
        switch productFilter.availabilityFilter {
        case .inStock:
            filtered = filtered.filter { $0.availability == .inStock }
        case .outOfStock:
            filtered = filtered.filter { $0.availability == .outOfStock }
        case .all:
            break
        }
        
        switch productFilter.sortBy {
        case .name:
            filtered = filtered.sorted { $0.name < $1.name }
        case .priceAsc:
            filtered = filtered.sorted { $0.price < $1.price }
        case .priceDesc:
            filtered = filtered.sorted { $0.price > $1.price }
        case .rating:
            filtered = filtered.sorted { $0.rating > $1.rating }
        }
        
        return filtered
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
                        
                        SearchBarView(text: $searchText, isSearchFocused: $isSearchFocused)
                            .onChange(of: searchText) { oldValue, newValue in
                                if !newValue.isEmpty && newValue.count >= 3 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        if searchText == newValue {
                                            AnalyticsManager.shared.logSearch(newValue, resultCount: filteredProducts.count)
                                        }
                                    }
                                }
                            }
                        
                        NavigationLink(destination: CartView(cartItems: $productItems)) {
                            ZStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.accentColor)
                                
                                if !productItems.isEmpty {
                                    Text("\(productItems.count)")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(minWidth: 18, minHeight: 18)
                                        .background(.red)
                                        .clipShape(Circle())
                                        .offset(x: 11, y: -11)
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
                        ForEach(Array(filteredProducts.enumerated()), id: \.element.id) { index, product in
                            NavigationLink(destination: ProductDetailView(product: product, cartItems: $productItems, likedProducts: $likedProducts)) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded {
                                AnalyticsManager.shared.logProductCardTapped(product, position: index)
                            })
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .onTapGesture {
                    if isSearchFocused {
                        isSearchFocused = false
                    }
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            if showingCategories {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        CategoriesSliderView(showingCategories: $showingCategories, productFilter: $productFilter)
                    }
                    .frame(width: 320)
                    .frame(maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 2, y: 0)
                    .ignoresSafeArea(.all)
                    .offset(x: showingCategories ? 0 : -320)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: showingCategories)
                    
                    Color.black.opacity(0.3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                                showingCategories = false
                            }
                        }
                        .ignoresSafeArea(.all)
                        .clipped()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .toolbar(showingCategories ? .hidden : .visible, for: .tabBar)
    }
}
