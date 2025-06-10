import SwiftUI

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    @State private var minValue: Double = 0
    @State private var maxValue: Double = 100000
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("₴\(Int(minValue))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("₴\(Int(maxValue))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    HStack {
                        Text("Min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        
                        Slider(
                            value: Binding(
                                get: { minValue },
                                set: { newValue in
                                    let clampedValue = max(bounds.lowerBound, min(newValue, maxValue - step))
                                    minValue = clampedValue
                                    updateRange()
                                }
                            ),
                            in: bounds.lowerBound...bounds.upperBound,
                            step: step
                        )
                        .accentColor(.accentColor)
                    }
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Max")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        
                        Slider(
                            value: Binding(
                                get: { maxValue },
                                set: { newValue in
                                    let clampedValue = min(bounds.upperBound, max(newValue, minValue + step))
                                    maxValue = clampedValue
                                    updateRange()
                                }
                            ),
                            in: bounds.lowerBound...bounds.upperBound,
                            step: step
                        )
                        .accentColor(.accentColor)
                    }
                }
            }
        }
        .onAppear {
            minValue = range.lowerBound
            maxValue = range.upperBound
        }
        .onChange(of: range) { oldRange, newRange in
            minValue = newRange.lowerBound
            maxValue = newRange.upperBound
        }
    }
    
    private func updateRange() {
        let validMin = max(bounds.lowerBound, min(minValue, maxValue))
        let validMax = min(bounds.upperBound, max(minValue, maxValue))
        range = validMin...validMax
    }
}
