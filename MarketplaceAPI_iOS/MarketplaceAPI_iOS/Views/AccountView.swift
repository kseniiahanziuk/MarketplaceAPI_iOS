import SwiftUI

struct AccountView: View {
    // needs more features and screens
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accent)
                        
                        VStack(alignment: .leading) {
                            Text("User")
                                .font(.headline)
                            Text("user@gmail.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: {
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
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
    }
}
