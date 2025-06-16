import SwiftUI

struct AccountView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userEmail") private var userEmail = "user@gmail.com"
    @State private var showingEditProfile = false
    @State private var showingOrderHistory = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    Button(action: {
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
                                Text("Tap to edit profile")
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
                
                Section("Orders") {
                    NavigationLink(destination: OrderHistoryView()) {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Order history")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: TrackOrderView()) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Track orders")
                            Spacer()
                        }
                    }
                }
                
                Section("Account") {
                    NavigationLink(destination: AddressView()) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Shipping address")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: PaymentMethodsView()) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Payment methods")
                            Spacer()
                        }
                    }
                }
                
                Section("Preferences") {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Dark mode")
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Notifications")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: LanguageSettingsView()) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Language")
                            Spacer()
                            Text("English")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Support") {
                    NavigationLink(destination: HelpCenterView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Help center")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: ContactSupportView()) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("Contact support")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            Text("About")
                            Spacer()
                        }
                    }
                }
                
                Section {
                    Button(action: logout) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Logout")
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
        .navigationTitle("Account")
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userName: $userName, userEmail: $userEmail)
        }
    }
    
    private func logout() {
        print("User logged out")
    }
}
