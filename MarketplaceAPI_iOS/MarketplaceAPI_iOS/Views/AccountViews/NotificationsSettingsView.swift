import SwiftUI

struct NotificationSettingsView: View {
    @State private var orderUpdates = true
    @State private var promotions = false
    @State private var newProducts = true
    
    var body: some View {
        Form {
            Section("Push notifications") {
                Toggle("Order updates", isOn: $orderUpdates)
                Toggle("Promotions", isOn: $promotions)
                Toggle("New products", isOn: $newProducts)
            }
        }
        .navigationTitle("Notifications")
    }
}
