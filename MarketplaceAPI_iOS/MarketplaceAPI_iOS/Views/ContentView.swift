import SwiftUI

struct ContentView: View {
    @Binding var productFilter: ProductFilter
    @State private var chosenTab = 0
    @StateObject private var appController = AppController()
    @State private var showingCategories = false
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView(selection: $chosenTab) {
            NavigationView {
                CatalogView(
                    productItems: $appController.cartItems,
                    likedProducts: $appController.likedProducts,
                    showingCategories: $showingCategories,
                    productFilter: $productFilter
                )
                .environmentObject(appController)
            }
            .tabItem {
                Image(systemName: "list.bullet.below.rectangle")
                Text(String(localized: "Catalog"))
            }
            .tag(0)
            
            NavigationView {
                LikedView(likedProducts: $appController.likedProducts)
                    .environmentObject(appController)
            }
            .tabItem {
                Image(systemName: "heart")
                Text(String(localized: "Liked"))
            }
            .tag(1)
            
            NavigationView {
                AccountView()
                    .environmentObject(appController)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text(String(localized: "Account"))
            }
            .tag(2)
        }
        .accentColor(.accentColor)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            AnalyticsManager.shared.logAppLaunch()
        }
        .onChange(of: chosenTab) { oldValue, newValue in
            let screenName = getScreenName(for: newValue)
            AnalyticsManager.shared.logScreenView(screenName)
        }
        .alert("Product Error", isPresented: $appController.catalogController.showError) {
            Button("OK") {
                appController.catalogController.showError = false
            }
        } message: {
            Text(appController.catalogController.errorMessage)
        }
        .alert("Order Error", isPresented: $appController.orderController.showError) {
            Button("OK") {
                appController.orderController.showError = false
            }
        } message: {
            Text(appController.orderController.errorMessage)
        }
        .alert("Order created", isPresented: $appController.orderController.orderCreated) {
            Button("OK") {
                appController.orderController.orderCreated = false
            }
        } message: {
            Text("Your order has been placed successfully!")
        }
    }
    
    private func getScreenName(for tab: Int) -> String {
        switch tab {
        case 0: return "catalog"
        case 1: return "liked"
        case 2: return "account"
        default: return "unknown"
        }
    }
}
