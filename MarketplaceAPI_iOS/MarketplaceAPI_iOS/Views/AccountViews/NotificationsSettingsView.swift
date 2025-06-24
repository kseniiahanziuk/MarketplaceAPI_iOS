import SwiftUI

struct NotificationSettingsView: View {
    @State private var orderUpdates = true
    @State private var promotions = false
    @State private var newProducts = true
    
    var body: some View {
        Form {
            Section("Push notifications") {
                Toggle("Order updates", isOn: $orderUpdates)
                    .onChange(of: orderUpdates) { oldValue, newValue in
                        AnalyticsManager.shared.logCustomEvent("notification_setting_changed", parameters: [
                            "setting_type": "order_updates",
                            "enabled": newValue
                        ])
                    }
                
                Toggle("Promotions", isOn: $promotions)
                    .onChange(of: promotions) { oldValue, newValue in
                        AnalyticsManager.shared.logCustomEvent("notification_setting_changed", parameters: [
                            "setting_type": "promotions",
                            "enabled": newValue
                        ])
                    }
                
                Toggle("New products", isOn: $newProducts)
                    .onChange(of: newProducts) { oldValue, newValue in
                        AnalyticsManager.shared.logCustomEvent("notification_setting_changed", parameters: [
                            "setting_type": "new_products",
                            "enabled": newValue
                        ])
                    }
            }
        }
        .navigationTitle("Notifications")
        .onAppear {
            AnalyticsManager.shared.logScreenView("notification_settings")
        }
    }
}
