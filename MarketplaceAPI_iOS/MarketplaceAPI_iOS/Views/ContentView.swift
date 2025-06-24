import SwiftUI

struct ContentView: View {
    @Binding var productFilter: ProductFilter
    @State private var chosenTab = 0
    @State private var productItems: [ProductItem] = []
    @State private var likedProducts: [Product] = []
    @State private var showingCategories = false
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView(selection: $chosenTab) {
            NavigationView {
                CatalogView(productItems: $productItems, likedProducts: $likedProducts, showingCategories: $showingCategories, productFilter: $productFilter)
            }
            .tabItem {
                Image(systemName: "list.bullet.below.rectangle")
                Text(String(localized: "Catalog"))
            }
            .tag(0)
            
            NavigationView {
                LikedView(likedProducts: $likedProducts)
            }
            .tabItem {
                Image(systemName: "heart")
                Text(String(localized: "Liked"))
            }
            .tag(1)
            
            NavigationView {
                AccountView()
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
            // simple crashlytics test for fatal error
            // CrashlyticsManager.shared.testCrash()
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
