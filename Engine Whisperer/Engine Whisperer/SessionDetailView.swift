import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct SessionDetailView: View {
    let session: EngineSession
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.ferrariDarkBackground : Color.ferrariIvory
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.ferrariDarkText : Color.ferrariDark
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.ferrariDarkSurface : Color.white
    }
    
    // Подготовка данных для графика
    private var chartData: [StatusDataPoint] {
        session.statuses.enumerated().map { index, status in
            StatusDataPoint(
                index: index,
                status: status,
                value: status.numericValue
            )
        }
    }
    
    // Статистика по статусам
    private var statusCounts: [EngineStatus: Int] {
        Dictionary(grouping: session.statuses, by: { $0 })
            .mapValues { $0.count }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок с информацией о сессии
                VStack(spacing: 12) {
                    Text(dateFormatter.string(from: session.date))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    
                    HStack(spacing: 16) {
                        StatusBadge(status: session.finalStatus)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label("\(Int(session.duration)) сек", systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Label("\(session.statuses.count) точек", systemImage: "waveform.path.ecg")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceColor)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // График истории статусов
                VStack(alignment: .leading, spacing: 12) {
                    Text("История статусов")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    #if canImport(Charts)
                    if #available(iOS 16.0, *) {
                        Chart(chartData) { dataPoint in
                            LineMark(
                                x: .value("Время", dataPoint.index),
                                y: .value("Статус", dataPoint.value)
                            )
                            .foregroundStyle(dataPoint.status.gradient)
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Время", dataPoint.index),
                                y: .value("Статус", dataPoint.value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        dataPoint.status.color.opacity(0.3),
                                        dataPoint.status.color.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 0...2)
                        .chartYAxis {
                            AxisMarks(values: [0, 1, 2]) { value in
                                AxisValueLabel {
                                    if let intValue = value.as(Int.self) {
                                        Text(EngineStatus.fromNumeric(intValue)?.title ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    } else {
                        // Fallback для iOS < 16
                        SimpleLineChart(data: chartData.map { $0.value })
                            .frame(height: 200)
                    }
                    #else
                    // Fallback если Charts недоступен
                    SimpleLineChart(data: chartData.map { $0.value })
                        .frame(height: 200)
                    #endif
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceColor)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Визуальная временная шкала
                VStack(alignment: .leading, spacing: 12) {
                    Text("Временная шкала")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    StatusTimeline(statuses: session.statuses)
                        .frame(height: 20)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceColor)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // Статистика по статусам
                VStack(alignment: .leading, spacing: 12) {
                    Text("Статистика")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    VStack(spacing: 8) {
                        ForEach(EngineStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(AnyShapeStyle(status.gradient))
                                    .frame(width: 16, height: 16)
                                
                                Text(status.description)
                                    .font(.subheadline)
                                    .foregroundColor(textColor)
                                
                                Spacer()
                                
                                Text("\(statusCounts[status] ?? 0)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(status.color)
                                
                                if session.statuses.count > 0 {
                                    Text("(\(Int(Double(statusCounts[status] ?? 0) / Double(session.statuses.count) * 100))%)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceColor)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("Детали сессии")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Структура для данных графика
struct StatusDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let status: EngineStatus
    let value: Double
}

// Расширение EngineStatus для числовых значений
extension EngineStatus {
    var numericValue: Double {
        switch self {
        case .normal: return 0
        case .warning: return 1
        case .critical: return 2
        }
    }
    
    static func fromNumeric(_ value: Int) -> EngineStatus? {
        switch value {
        case 0: return .normal
        case 1: return .warning
        case 2: return .critical
        default: return nil
        }
    }
}

// Компонент для отображения статуса
struct StatusBadge: View {
    let status: EngineStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AnyShapeStyle(status.gradient))
                .frame(width: 12, height: 12)
            
            Text(status.title)
                .font(.headline)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(status.color.opacity(0.15))
        )
    }
}

// Простой график для iOS < 16
struct SimpleLineChart: View {
    let data: [Double]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !data.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let maxValue = data.max() ?? 1
                let minValue = data.min() ?? 0
                let range = maxValue - minValue
                
                let stepX = width / CGFloat(max(data.count - 1, 1))
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                    let y = height * (1 - normalizedValue)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [Color.ferrariRed, Color.red.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

