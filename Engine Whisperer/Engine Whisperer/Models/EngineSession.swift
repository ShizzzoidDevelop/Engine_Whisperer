import Foundation

struct EngineSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let finalStatus: EngineStatus
    let statuses: [EngineStatus]
}



