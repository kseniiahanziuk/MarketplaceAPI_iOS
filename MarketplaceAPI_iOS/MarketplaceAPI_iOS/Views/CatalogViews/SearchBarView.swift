import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            
            TextField("Search products", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isSearchFocused)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
