import SwiftUI

struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    private var colorValue: Color {
        switch color.lowercased() {
        case "black": return .black
        case "white": return .white
        case "silver": return .gray
        case "gold": return .yellow
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(colorValue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 3)
                            .frame(width: 40, height: 40)
                    }
                }
                
                Text(color)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
