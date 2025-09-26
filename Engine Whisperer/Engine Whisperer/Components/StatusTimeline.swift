import SwiftUI

struct StatusTimeline: View {
    let statuses: [EngineStatus]
    
    private func color(for status: EngineStatus) -> Color {
        switch status {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .ferrariRed
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let barCount = max(statuses.count, 1)
            let spacing: CGFloat = 1
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = max((geometry.size.width - totalSpacing), 1) / CGFloat(barCount)
            
            HStack(alignment: .center, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color(for: statuses[idx]))
                        .frame(width: barWidth, height: geometry.size.height)
                }
            }
        }
        .frame(height: 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .accessibilityIdentifier("StatusTimeline")
    }
}


