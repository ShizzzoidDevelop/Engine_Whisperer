import Foundation
import UIKit

struct ProjectSettings {
    
    // MARK: - Project Configuration
    
    static func configureForDevice() {
        let device = UIDevice.current
        
        // Настройки для iPhone
        if device.userInterfaceIdiom == .phone {
            configureForiPhone()
        }
        
        // Настройки для iPad
        if device.userInterfaceIdiom == .pad {
            configureForiPad()
        }
    }
    
    private static func configureForiPhone() {
        // Оптимизация для iPhone
        Constants.UI.amplitudeBarCount = 30
        Constants.UI.frequencyBarCount = 20
        Constants.Audio.sampleRate = 44100
    }
    
    private static func configureForiPad() {
        // Оптимизация для iPad
        Constants.UI.amplitudeBarCount = 50
        Constants.UI.frequencyBarCount = 40
        Constants.Audio.sampleRate = 48000
    }
    
    // MARK: - iOS Version Configuration
    
    static func configureForiOSVersion() {
        let systemVersion = UIDevice.current.systemVersion
        
        if #available(iOS 18.0, *) {
            configureForiOS18Plus()
        } else if #available(iOS 17.0, *) {
            configureForiOS17Plus()
        } else if #available(iOS 16.0, *) {
            configureForiOS16Plus()
        } else {
            configureForLegacyiOS()
        }
    }
    
    @available(iOS 18.0, *)
    private static func configureForiOS18Plus() {
        // Настройки для iOS 18+
        Constants.Audio.bufferSize = 2048
        Constants.Audio.fftSize = 2048
        Constants.UI.amplitudeBarCount = 40
        Constants.UI.frequencyBarCount = 30
    }
    
    @available(iOS 17.0, *)
    private static func configureForiOS17Plus() {
        // Настройки для iOS 17
        Constants.Audio.bufferSize = 1536
        Constants.Audio.fftSize = 1536
        Constants.UI.amplitudeBarCount = 35
        Constants.UI.frequencyBarCount = 25
    }
    
    @available(iOS 16.0, *)
    private static func configureForiOS16Plus() {
        // Настройки для iOS 16
        Constants.Audio.bufferSize = 1024
        Constants.Audio.fftSize = 1024
        Constants.UI.amplitudeBarCount = 30
        Constants.UI.frequencyBarCount = 20
    }
    
    private static func configureForLegacyiOS() {
        // Настройки для старых версий iOS
        Constants.Audio.bufferSize = 512
        Constants.Audio.fftSize = 512
        Constants.UI.amplitudeBarCount = 20
        Constants.UI.frequencyBarCount = 15
    }
    
    // MARK: - Performance Configuration
    
    static func configureForPerformance() {
        let processorCount = ProcessInfo.processInfo.processorCount
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        
        // Настройки на основе количества ядер процессора
        if processorCount >= 8 {
            // A14 Bionic и новее
            Constants.Audio.bufferSize = 2048
            Constants.Audio.fftSize = 2048
            Constants.UI.amplitudeBarCount = 50
            Constants.UI.frequencyBarCount = 40
        } else if processorCount >= 6 {
            // A12 Bionic
            Constants.Audio.bufferSize = 1536
            Constants.Audio.fftSize = 1536
            Constants.UI.amplitudeBarCount = 40
            Constants.UI.frequencyBarCount = 30
        } else {
            // Старые процессоры
            Constants.Audio.bufferSize = 1024
            Constants.Audio.fftSize = 1024
            Constants.UI.amplitudeBarCount = 30
            Constants.UI.frequencyBarCount = 20
        }
        
        // Настройки на основе объема памяти
        if physicalMemory >= 6 * 1024 * 1024 * 1024 { // 6GB+
            Constants.UI.amplitudeBarCount = 60
            Constants.UI.frequencyBarCount = 50
        } else if physicalMemory >= 4 * 1024 * 1024 * 1024 { // 4GB+
            Constants.UI.amplitudeBarCount = 50
            Constants.UI.frequencyBarCount = 40
        }
    }
    
    // MARK: - Device-Specific Configuration
    
    static func configureForSpecificDevice() {
        let deviceModel = getDeviceModel()
        
        switch deviceModel {
        case "iPhone15,2", "iPhone15,3": // iPhone 14
            configureForiPhone14()
            
        case "iPhone14,2", "iPhone14,3": // iPhone 13
            configureForiPhone13()
            
        case "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4": // iPhone 12
            configureForiPhone12()
            
        case "iPhone12,1", "iPhone12,3", "iPhone12,5": // iPhone 11
            configureForiPhone11()
            
        default:
            configureForGenericDevice()
        }
    }
    
    private static func configureForiPhone14() {
        Constants.Audio.sampleRate = 48000
        Constants.Audio.bufferSize = 2048
        Constants.Audio.fftSize = 2048
        Constants.UI.amplitudeBarCount = 60
        Constants.UI.frequencyBarCount = 50
    }
    
    private static func configureForiPhone13() {
        Constants.Audio.sampleRate = 44100
        Constants.Audio.bufferSize = 1536
        Constants.Audio.fftSize = 1536
        Constants.UI.amplitudeBarCount = 50
        Constants.UI.frequencyBarCount = 40
    }
    
    private static func configureForiPhone12() {
        Constants.Audio.sampleRate = 44100
        Constants.Audio.bufferSize = 1024
        Constants.Audio.fftSize = 1024
        Constants.UI.amplitudeBarCount = 40
        Constants.UI.frequencyBarCount = 30
    }
    
    private static func configureForiPhone11() {
        Constants.Audio.sampleRate = 44100
        Constants.Audio.bufferSize = 1024
        Constants.Audio.fftSize = 1024
        Constants.UI.amplitudeBarCount = 35
        Constants.UI.frequencyBarCount = 25
    }
    
    private static func configureForGenericDevice() {
        Constants.Audio.sampleRate = 44100
        Constants.Audio.bufferSize = 1024
        Constants.Audio.fftSize = 1024
        Constants.UI.amplitudeBarCount = 30
        Constants.UI.frequencyBarCount = 20
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
    
    // MARK: - Debug Configuration
    
    static func configureForDebug() {
        #if DEBUG
        Constants.Audio.bufferSize = 512
        Constants.Audio.fftSize = 512
        Constants.UI.amplitudeBarCount = 20
        Constants.UI.frequencyBarCount = 15
        #endif
    }
    
    // MARK: - Release Configuration
    
    static func configureForRelease() {
        #if !DEBUG
        configureForPerformance()
        configureForSpecificDevice()
        #endif
    }
}
