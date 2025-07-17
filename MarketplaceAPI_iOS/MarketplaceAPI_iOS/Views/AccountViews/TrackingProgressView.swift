import Foundation
import SwiftUI

struct TrackingProgressView: View {
    let status: OrderStatus
    
    private var progress: CGFloat {
        switch status {
        case .pending: return 0.25
        case .confirmed: return 0.5
        case .shipped: return 0.75
        case .delivered: return 1.0
        case .cancelled: return 0.0
        }
    }
    
    private var statusSteps: [(String, Bool)] {
        let steps = [
            ("Pending", true),
            ("Confirmed", status != .pending && status != .cancelled),
            ("Shipped", status == .shipped || status == .delivered),
            ("Delivered", status == .delivered)
        ]
        return steps
    }
    
    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(status == .cancelled ? Color.red : Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            
            HStack {
                ForEach(Array(statusSteps.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(step.1 ? (status == .cancelled ? Color.red : Color.accentColor) : Color(.systemGray5))
                            .frame(width: 8, height: 8)
                        
                        Text(step.0)
                            .font(.caption2)
                            .foregroundColor(step.1 ? .primary : .secondary)
                    }
                    
                    if index < statusSteps.count - 1 {
                        Spacer()
                    }
                }
            }
            
            if status == .cancelled {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Order cancelled")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
            }
        }
    }
}
