import SwiftUI

struct AccountView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userEmail") private var userEmail = "user@gmail.com"
    @State private var showingEditProfile = false
    @State private var showingOrderHistory = false
    @State private var showingSettings = false
    @StateObject private var localization = LocalizationHelper.shared
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    Button(action: {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "edit_profile"
                        ])
                        showingEditProfile = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(userName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(userEmail)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(String(localized: "Tap to edit profile"))
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section(String(localized: "Orders")) {
                    NavigationLink(destination: OrderHistoryView()) {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Order history"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "order_history",
                            "section": "orders"
                        ])
                    })
                    
                    NavigationLink(destination: TrackOrderView()) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Track orders"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "track_orders",
                            "section": "orders"
                        ])
                    })
                }
                
                Section(String(localized: "Account")) {
                    NavigationLink(destination: AddressView()) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Shipping address"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "shipping_address",
                            "section": "account"
                        ])
                    })
                    
                    NavigationLink(destination: PaymentMethodsView()) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Payment methods"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "payment_methods",
                            "section": "account"
                        ])
                    })
                }
                
                Section(String(localized: "Preferences")) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text(String(localized: "Light/Dark mode"))
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .onChange(of: isDarkMode) { oldValue, newValue in
                                AnalyticsManager.shared.logCustomEvent("theme_changed", parameters: [
                                    "new_theme": newValue ? "dark" : "light",
                                    "previous_theme": oldValue ? "dark" : "light"
                                ])
                            }
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Notifications"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "notifications",
                            "section": "preferences"
                        ])
                    })
                    
                    NavigationLink(destination: LanguageSettingsView()) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Language"))
                            Spacer()
                            Text(localization.currentLanguageDisplayName)
                                .foregroundColor(.secondary)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "language",
                            "section": "preferences"
                        ])
                    })
                }
                
                Section(String(localized: "Support")) {
                    NavigationLink(destination: HelpCenterView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Help center"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "help_center",
                            "section": "support"
                        ])
                    })
                    
                    NavigationLink(destination: ContactSupportView()) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "Contact support"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "contact_support",
                            "section": "support"
                        ])
                    })
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text(String(localized: "About"))
                            Spacer()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        AnalyticsManager.shared.logCustomEvent("account_action_tapped", parameters: [
                            "action": "about",
                            "section": "support"
                        ])
                    })
                }
                
                Section {
                    Button(action: logout) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text(String(localized: "Logout"))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .navigationTitle(String(localized: "Account"))
        .onAppear {
            AnalyticsManager.shared.logScreenView("account")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userName: $userName, userEmail: $userEmail)
        }
    }
    
    private func logout() {
        AnalyticsManager.shared.logCustomEvent("user_logout", parameters: [
            "logout_timestamp": Date().timeIntervalSince1970,
            "user_email": userEmail
        ])
        print("User logged out")
    }
}
