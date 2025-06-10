import SwiftUI

struct ContentView: View {
    @Binding var productFilter: ProductFilter
    @State private var chosenTab = 0
    @State private var productItems: [ProductItem] = []
    @State private var showingCategories = false
    
    var body: some View {
        TabView(selection: $chosenTab) {
            NavigationView {
                CatalogView(productItems: $productItems, showingCategories: $showingCategories, productFilter: $productFilter)
            }
            .tabItem {
                Image(systemName: "list.bullet.below.rectangle")
                Text("Catalog")
            }
            .tag(0)
            
            NavigationView {
                LikedView()
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Liked")
            }
            .tag(1)
            
            NavigationView {
                AccountView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Account")
            }
            .tag(2)
        }
        .accentColor(.accentColor)
    }
}
