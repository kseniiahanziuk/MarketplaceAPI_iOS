import SwiftUI

@main
struct MarketplaceAPI_iOSApp: App {
    @State private var productFilter = ProductFilter()
    
    var body: some Scene {
        WindowGroup {
            ContentView(productFilter: $productFilter)
        }
    }
}
