import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSession: EngineSession?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var textColor: Color {
        colorScheme == .dark ? Color.ferrariDarkText : Color.ferrariDark
    }
    
    var body: some View {
        NavigationView {
            Group {
                if historyStore.sessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 40))
                            .foregroundColor(.ferrariRed.opacity(0.6))
                        Text("История пуста")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Text("После завершения анализа сессии будут отображаться здесь.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        ForEach(historyStore.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(dateFormatter.string(from: session.date))
                                            .font(.headline)
                                            .foregroundColor(textColor)
                                        Spacer()
                                        Text(session.finalStatus.title)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(session.finalStatus.color.opacity(0.2))
                                            )
                                            .foregroundColor(session.finalStatus.color)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        Label(
                                            "\(Int(session.duration)) c",
                                            systemImage: "clock"
                                        )
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        
                                        Label(
                                            "\(session.statuses.count) точек анализа",
                                            systemImage: "waveform.path.ecg"
                                        )
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("История")
        }
    }
}



