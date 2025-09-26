import SwiftUI

struct FrequencyAnalyzer: View {
    var frequencyData: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let barWidth = (width - 20) / CGFloat(frequencyData.count)
            let maxFrequency = frequencyData.max() ?? 1
            
            ZStack {
                // Фон
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ЧАСТОТНЫЙ АНАЛИЗ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Constants.Colors.ferrariDark.opacity(0.7))
                        .tracking(1)
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(0..<frequencyData.count, id: \.self) { index in
                            let frequency = frequencyData[index]
                            let normalizedHeight = CGFloat(frequency / maxFrequency) * (height - 40)
                            
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.8),
                                                Color.blue.opacity(0.4)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: barWidth,
                                        height: max(normalizedHeight, 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    FrequencyAnalyzer(frequencyData: Array(repeating: 0.5, count: 20))
        .frame(height: 100)
        .padding()
}
