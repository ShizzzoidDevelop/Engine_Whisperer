import Foundation
import Combine

final class HistoryStore: ObservableObject {
    @Published private(set) var sessions: [EngineSession] = [] {
        didSet {
            save()
        }
    }
    
    private let storageKey = "engine_sessions_history"
    
    init() {
        load()
    }
    
    func addSession(_ session: EngineSession) {
        // Добавляем новые сессии в начало списка
        sessions.insert(session, at: 0)
    }
    
    func clear() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([EngineSession].self, from: data)
            sessions = decoded
        } catch {
            print("Failed to load sessions: \(error)")
            sessions = []
        }
    }
}



