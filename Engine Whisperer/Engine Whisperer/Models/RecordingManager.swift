
import AVFoundation
import Combine

class RecordingManager: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var recordingQuality: RecordingQuality = .high
    
    private var recordingTimer: Timer?
    private var startTime: Date?
    
    enum RecordingQuality {
        case low, medium, high
        
        var sampleRate: Double {
            switch self {
            case .low: return 22050
            case .medium: return 44100
            case .high: return 48000
            }
        }
        
        var description: String {
            switch self {
            case .low: return "Низкое"
            case .medium: return "Среднее"
            case .high: return "Высокое"
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        startTime = Date()
        recordingDuration = 0
        
        // Запускаем таймер для отслеживания длительности
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = self.startTime {
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        startTime = nil
    }
    
    func resetRecording() {
        stopRecording()
        recordingDuration = 0
    }
    
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
