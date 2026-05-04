import SwiftUI

struct StatusIndicator: View {
    let status: EngineStatus
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(EngineStatus.allCases, id: \.self) { item in
                VStack(spacing: 6) {
                    Circle()
                        .fill(status == item ? AnyShapeStyle(item.gradient) : AnyShapeStyle(Color.gray.opacity(0.2)))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(status == item ? Color.ferrariDark : .clear, lineWidth: 2)
                        )
                        .shadow(color: status == item ? item.color.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                    
                    Text(item.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(status == item ? .ferrariDark : .gray)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .accessibilityIdentifier("StatusIndicator")
    }
}

enum EngineStatus: String, CaseIterable, Codable {
    case normal, warning, critical
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .ferrariRed
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .normal:
            return LinearGradient(
                colors: [Color.green, Color.green.opacity(0.7), Color.mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warning:
            return LinearGradient(
                colors: [Color.yellow, Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .critical:
            return LinearGradient(
                colors: [Color.ferrariRed, Color.red.opacity(0.8), Color.ferrariRed.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var title: String {
        switch self {
        case .normal: return "OK"
        case .warning: return "WARN"
        case .critical: return "CRIT"
        }
    }
    
    var description: String {
        switch self {
        case .normal: return "Двигатель в норме"
        case .warning: return "Обнаружены незначительные проблемы"
        case .critical: return "Требуется срочная диагностика!"
        }
    }
}
