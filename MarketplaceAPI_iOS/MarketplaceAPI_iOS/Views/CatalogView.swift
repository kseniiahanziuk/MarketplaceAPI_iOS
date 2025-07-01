import SwiftUI

struct CatalogView: View {
    @Binding var productItems: [ProductItem]
    @Binding var likedProducts: [Product]
    @Binding var showingCategories: Bool
    @Binding var productFilter: ProductFilter
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @EnvironmentObject var appController: AppController
    
    var totalCartQuantity: Int {
        appController.getCartItemCount()
    }
    
    var displayProducts: [Product] {
        return appController.catalogController.products
    }
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                contentView
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            if showingCategories {
                categoriesOverlay
            }
        }
        .navigationBarHidden(true)
        .toolbar(showingCategories ? .hidden : .visible, for: .tabBar)
        .onAppear {
            AnalyticsManager.shared.logScreenView("catalog")
        }
        .onChange(of: searchText) { oldValue, newValue in
            if newValue.count >= 3 {
                appController.searchProducts(newValue, filter: productFilter)
            } else if newValue.isEmpty {
                appController.catalogController.refreshProducts(filter: productFilter)
            }
        }
        .onChange(of: productFilter) { oldValue, newValue in
            appController.applyFilter(newValue, searchTerm: searchText)
        }
        .alert("Error", isPresented: $appController.catalogController.showError) {
            Button("OK") {
                appController.catalogController.showError = false
            }
        } message: {
            Text(appController.catalogController.errorMessage)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                        showingCategories = true
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                }
                
                SearchBarView(text: $searchText, isSearchFocused: $isSearchFocused)
                
                NavigationLink(destination: CartView(cartItems: $productItems).environmentObject(appController)) {
                    ZStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.accentColor)
                        
                        if totalCartQuantity > 0 {
                            Text("\(totalCartQuantity)")
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
    }
    
    private var contentView: some View {
        Group {
            if appController.catalogController.isLoading && displayProducts.isEmpty {
                loadingView
            } else if displayProducts.isEmpty {
                emptyStateView
            } else {
                productGridView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading products...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No products found")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Try adjusting your search or filters.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var productGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(Array(displayProducts.enumerated()), id: \.element.id) { index, product in
                    NavigationLink(destination: ProductDetailView(
                        product: product,
                        cartItems: $productItems,
                        likedProducts: $likedProducts
                    ).environmentObject(appController)) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logProductCardTapped(product, position: index)
                    })
                    .onAppear {
                        if index == displayProducts.count - 3 {
                            appController.loadMoreProducts(filter: productFilter, searchTerm: searchText)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .refreshable {
            appController.catalogController.refreshProducts(filter: productFilter, searchTerm: searchText)
        }
        .onTapGesture {
            if isSearchFocused {
                isSearchFocused = false
            }
        }
    }
    
    private var categoriesOverlay: some View {
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
