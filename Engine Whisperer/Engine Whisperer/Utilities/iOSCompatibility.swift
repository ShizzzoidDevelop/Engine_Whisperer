import AVFoundation
import UIKit

struct iOSCompatibility {
    
    // MARK: - iOS 18+ Compatibility
    
    @available(iOS 18.0, *)
    static func requestMicrophonePermission() async -> Bool {
        return await AVAudioApplication.requestRecordPermission()
    }
    
    @available(iOS 18.0, *)
    static func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setPreferredSampleRate(44100)
        try audioSession.setPreferredInputNumberOfChannels(1)
        try audioSession.setActive(true)
    }
    
    // MARK: - iPhone 12+ Optimization
    
    static func optimizeForDevice() {
        // Оптимизация для iPhone 12 и новее
        if ProcessInfo.processInfo.processorCount >= 6 {
            // Увеличиваем размер буфера для более мощных процессоров
            Constants.Audio.bufferSize = 2048
            Constants.Audio.fftSize = 2048
        }
        
        // Оптимизация для устройств с большим объемом RAM
        if ProcessInfo.processInfo.physicalMemory >= 4 * 1024 * 1024 * 1024 { // 4GB+
            Constants.UI.amplitudeBarCount = 50
            Constants.UI.frequencyBarCount = 40
        }
    }
    
    // MARK: - iOS Version Detection
    
    static func isiOS18OrLater() -> Bool {
        if #available(iOS 18.0, *) {
            return true
        }
        return false
    }
    
    static func isiPhone12OrLater() -> Bool {
        // Проверяем по характеристикам устройства
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        
        // iPhone 12 был выпущен с iOS 14, но мы поддерживаем iOS 15+
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }
    
    // MARK: - Performance Optimization
    
    static func optimizeForPerformance() {
        // Оптимизация производительности для разных устройств
        let processorCount = ProcessInfo.processInfo.processorCount
        
        if processorCount >= 8 {
            // A14 Bionic и новее (iPhone 12+)
            Constants.Audio.bufferSize = 2048
            Constants.Audio.fftSize = 2048
        } else if processorCount >= 6 {
            // A12 Bionic (iPhone XS, XR)
            Constants.Audio.bufferSize = 1536
            Constants.Audio.fftSize = 1536
        } else {
            // Старые устройства
            Constants.Audio.bufferSize = 1024
            Constants.Audio.fftSize = 1024
        }
    }
    
    // MARK: - Memory Management
    
    static func optimizeMemoryUsage() {
        // Оптимизация использования памяти
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        
        if physicalMemory >= 6 * 1024 * 1024 * 1024 { // 6GB+
            // iPhone 13 Pro и новее
            Constants.UI.amplitudeBarCount = 60
            Constants.UI.frequencyBarCount = 50
        } else if physicalMemory >= 4 * 1024 * 1024 * 1024 { // 4GB+
            // iPhone 12 и новее
            Constants.UI.amplitudeBarCount = 40
            Constants.UI.frequencyBarCount = 30
        } else {
            // Старые устройства
            Constants.UI.amplitudeBarCount = 30
            Constants.UI.frequencyBarCount = 20
        }
    }
    
    // MARK: - Audio Quality Optimization
    
    static func optimizeAudioQuality() {
        // Оптимизация качества аудио для разных устройств
        let device = UIDevice.current
        
        if device.userInterfaceIdiom == .phone {
            // iPhone
            Constants.Audio.sampleRate = 44100
        } else {
            // iPad
            Constants.Audio.sampleRate = 48000
        }
    }
    
    // MARK: - Background Processing
    
    static func configureBackgroundProcessing() {
        // Настройка фоновой обработки для iOS 18+
        if #available(iOS 18.0, *) {
            // Включаем фоновую обработку аудио
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            } catch {
                print("Ошибка настройки фоновой обработки: \(error)")
            }
        }
    }
    
    // MARK: - Device-Specific Optimizations
    
    static func applyDeviceSpecificOptimizations() {
        let deviceModel = getDeviceModel()
        
        switch deviceModel {
        case "iPhone15,2", "iPhone15,3": // iPhone 14
            Constants.Audio.sampleRate = 48000
            Constants.Audio.bufferSize = 2048
            
        case "iPhone14,2", "iPhone14,3": // iPhone 13
            Constants.Audio.sampleRate = 44100
            Constants.Audio.bufferSize = 1536
            
        case "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4": // iPhone 12
            Constants.Audio.sampleRate = 44100
            Constants.Audio.bufferSize = 1024
            
        default:
            // Стандартные настройки
            Constants.Audio.sampleRate = 44100
            Constants.Audio.bufferSize = 1024
        }
    }
    
    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown"
    }
}
