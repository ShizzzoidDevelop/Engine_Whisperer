import SwiftUI

struct StatusTimeline: View {
    let statuses: [EngineStatus]
    @Environment(\.colorScheme) var colorScheme
    
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.ferrariDarkSurface : Color.white
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
                        .fill(AnyShapeStyle(statuses[idx].gradient))
                        .frame(width: barWidth, height: geometry.size.height)
                }
            }
        }
        .frame(height: 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(surfaceColor)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 1)
        )
        .accessibilityIdentifier("StatusTimeline")
    }
}


