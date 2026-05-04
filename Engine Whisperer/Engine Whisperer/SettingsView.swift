import SwiftUI

struct SettingsView: View {
    @ObservedObject var historyStore: HistoryStore
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Хранилище")) {
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Очистить историю и кэш")
                        }
                    }
                    .alert("Очистить историю?", isPresented: $showClearAlert) {
                        Button("Отмена", role: .cancel) {}
                        Button("Очистить", role: .destructive) {
                            historyStore.clear()
                        }
                    } message: {
                        Text("Все сохранённые сессии анализа будут удалены с этого устройства.")
                    }
                    
                    if !historyStore.sessions.isEmpty {
                        Text("Сохранённых сессий: \(historyStore.sessions.count)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Engine Whisperer")
                        Spacer()
                        Text("v1.0")
                            .foregroundColor(.gray)
                    }
                    
                    Text("Приложение для анализа звука двигателя с сохранением истории проверок на устройстве.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("Настройки")
        }
    }
}



