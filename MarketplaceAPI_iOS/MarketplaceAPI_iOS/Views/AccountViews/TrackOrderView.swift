import SwiftUI

struct TrackOrderView: View {
    var body: some View {
        VStack {
            Image(systemName: "location")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No orders to track")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Track orders")
    }
}
