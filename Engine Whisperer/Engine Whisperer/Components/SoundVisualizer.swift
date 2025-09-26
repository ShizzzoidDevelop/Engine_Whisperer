import SwiftUI

struct SoundVisualizer: View {
    var levels: [CGFloat]
    
    private let minBarHeight: CGFloat = 4
    private let barSpacing: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(geometry.size.width - 20, 1)
            let count = max(levels.count, 1)
            let barWidth = max((availableWidth - (barSpacing * CGFloat(count - 1))) / CGFloat(count), 2)
            let maxLevel = max(levels.max() ?? 1, 0.001)
            
            ZStack {
                // Фон визуализатора
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                
                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(0..<count, id: \.self) { index in
                        let value = levels[index]
                        let normalized = CGFloat(value / maxLevel)
                        let targetHeight = max(normalized * (geometry.size.height - 20), minBarHeight)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.ferrariRed, .ferrariRed.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: barWidth, height: targetHeight)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .animation(.easeOut(duration: 0.18), value: levels)
            }
        }
        .accessibilityIdentifier("SoundVisualizer")
    }
}
