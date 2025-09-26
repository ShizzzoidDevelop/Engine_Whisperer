import SwiftUI

struct StatusIndicator: View {
    let status: EngineStatus
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(EngineStatus.allCases, id: \.self) { item in
                VStack(spacing: 6) {
                    Circle()
                        .fill(status == item ? item.color : Color.gray.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(status == item ? Color.ferrariDark : .clear, lineWidth: 2)
                        )
                    
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

enum EngineStatus: CaseIterable {
    case normal, warning, critical
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .critical: return .ferrariRed
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
