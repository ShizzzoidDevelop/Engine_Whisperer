import SwiftUI

struct Constants {
    
    // MARK: - Audio Settings
    struct Audio {
        static var sampleRate: Double = 44100
        static var bufferSize: Int = 1024
        static var fftSize: Int = 1024
        static let maxRPM: Int = 8000
        static let minRPM: Int = 0
    }
    
    // MARK: - Analysis Thresholds
    struct Analysis {
        static let criticalNoiseLevel: Float = -20.0
        static let warningNoiseLevel: Float = -40.0
        static let quietNoiseLevel: Float = -60.0
        static let peakThreshold: Float = 0.1
        static let highFrequencyThreshold: Float = 0.5
    }
    
    // MARK: - UI Constants
    struct UI {
        static var amplitudeBarCount: Int = 30
        static var frequencyBarCount: Int = 20
        static let animationDuration: Double = 0.3
        static let updateInterval: Double = 0.1
    }
    
    // MARK: - Colors
    struct Colors {
        static let ferrariRed = Color(red: 0.78, green: 0.06, blue: 0.11)
        static let ferrariIvory = Color(red: 1.0, green: 0.99, blue: 0.94)
        static let ferrariDark = Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    // MARK: - Messages
    struct Messages {
        static let microphonePermissionRequired = "Требуется доступ к микрофону"
        static let microphonePermissionDescription = "Для анализа двигателя необходимо разрешение на использование микрофона"
        static let microphoneUnavailable = "Микрофон недоступен"
        static let noPermission = "Нет разрешения на запись"
        static let audioSetupError = "Ошибка настройки аудио"
        static let engineAnalysisInProgress = "Анализ звука двигателя..."
        static let analysisComplete = "Анализ завершен"
    }
}
