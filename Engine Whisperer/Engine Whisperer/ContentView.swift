import SwiftUI
import AVFoundation

// Расширение для цветов Ferrari
extension Color {
    static let ferrariRed = Constants.Colors.ferrariRed
    static let ferrariIvory = Constants.Colors.ferrariIvory
    static let ferrariDark = Constants.Colors.ferrariDark
    
    // Dark theme colors
    static let ferrariDarkBackground = Constants.Colors.ferrariDarkBackground
    static let ferrariDarkSurface = Constants.Colors.ferrariDarkSurface
    static let ferrariDarkText = Constants.Colors.ferrariDarkText
    static let ferrariDarkRed = Constants.Colors.ferrariDarkRed
}

struct ContentView: View {
    @StateObject private var audioAnalyzer = AudioAnalyzer()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var recordingManager = RecordingManager()
    @StateObject private var historyStore = HistoryStore()
    
    var body: some View {
        TabView {
            AnalyzerView(
                audioAnalyzer: audioAnalyzer,
                permissionManager: permissionManager,
                recordingManager: recordingManager,
                historyStore: historyStore
            )
            .tabItem {
                Image(systemName: "waveform")
                Text("Главная")
            }
            
            HistoryView(historyStore: historyStore)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("История")
                }
            
            SettingsView(historyStore: historyStore)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Настройки")
                }
        }
        .preferredColorScheme(nil) // Поддержка автоматической темной темы
    }
}

// Компонент для показателей
struct IndicatorItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.ferrariDarkSurface : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.ferrariDarkText : Color.ferrariDark
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(textColor.opacity(0.7))
                    .tracking(1)
                    .contentTransition(.opacity)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(textColor)
                    .contentTransition(.numericText())
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(surfaceColor)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 5, x: 0, y: 2)
        )
    }
}
