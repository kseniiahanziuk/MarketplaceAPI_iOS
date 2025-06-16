import SwiftUI

struct EditProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    @Environment(\.dismiss) private var dismiss
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile information") {
                    HStack {
                        Text("Name")
                        TextField("Enter your name", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Email")
                        TextField("Enter your email", text: $tempEmail)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                    }
                }
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userName = tempName
                        userEmail = tempEmail
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempName = userName
            tempEmail = userEmail
        }
    }
}
