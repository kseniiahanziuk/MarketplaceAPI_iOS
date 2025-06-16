import SwiftUI

struct ContactSupportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "headphones")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Contact support")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Need help? Our support team is here to assist you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Contact support")
    }
}
