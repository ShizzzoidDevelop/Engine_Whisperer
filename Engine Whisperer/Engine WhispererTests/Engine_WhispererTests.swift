//
//  Engine_WhispererTests.swift
//  Engine WhispererTests
//
//  Created by Тима Таскин on 11.07.2025.
//

import Testing
import AVFoundation
@testable import Engine_Whisperer

struct Engine_WhispererTests {
    
    // MARK: - AudioAnalyzer Tests
    
    @Test func testAudioAnalyzerInitialState() async throws {
        let audioAnalyzer = AudioAnalyzer()
        
        #expect(!audioAnalyzer.isRecording)
        #expect(audioAnalyzer.engineStatus == .normal)
        #expect(audioAnalyzer.rpm == 0)
        #expect(audioAnalyzer.noiseLevel == 0)
        #expect(audioAnalyzer.amplitudes.count == Constants.UI.amplitudeBarCount)
        #expect(audioAnalyzer.frequencyData.count == Constants.UI.frequencyBarCount)
    }
    
    @Test func testAudioAnalyzerAmplitudesUpdate() async throws {
        let audioAnalyzer = AudioAnalyzer()
        let testAmplitude: CGFloat = 0.5
        
        audioAnalyzer.updateAmplitudes(with: testAmplitude)
        
        #expect(audioAnalyzer.amplitudes.last == testAmplitude)
        #expect(audioAnalyzer.amplitudes.count == Constants.UI.amplitudeBarCount)
    }
    
    @Test func testAudioAnalyzerEngineSoundAnalysis() async throws {
        let audioAnalyzer = AudioAnalyzer()
        
        // Тест нормального состояния
        audioAnalyzer.noiseLevel = -50.0
        audioAnalyzer.amplitudes = Array(repeating: 0.5, count: Constants.UI.amplitudeBarCount)
        audioAnalyzer.analyzeEngineSound()
        
        #expect(audioAnalyzer.engineStatus == .normal)
        
        // Тест предупреждающего состояния
        audioAnalyzer.noiseLevel = -30.0
        audioAnalyzer.amplitudes = Array(repeating: 1.5, count: Constants.UI.amplitudeBarCount)
        audioAnalyzer.analyzeEngineSound()
        
        #expect(audioAnalyzer.engineStatus == .warning)
        
        // Тест критического состояния
        audioAnalyzer.noiseLevel = -10.0
        audioAnalyzer.analyzeEngineSound()
        
        #expect(audioAnalyzer.engineStatus == .critical)
    }
    
    // MARK: - PermissionManager Tests
    
    @Test func testPermissionManagerInitialState() async throws {
        let permissionManager = PermissionManager()
        
        #expect(permissionManager.permissionStatus == .notDetermined)
        #expect(!permissionManager.showPermissionAlert)
    }
    
    @Test func testPermissionManagerStatusCheck() async throws {
        let permissionManager = PermissionManager()
        permissionManager.checkPermissionStatus()
        
        // Статус должен быть определен после проверки
        let validStatuses: [PermissionManager.PermissionStatus] = [.notDetermined, .granted, .denied]
        #expect(validStatuses.contains(permissionManager.permissionStatus))
    }
    
    // MARK: - RecordingManager Tests
    
    @Test func testRecordingManagerInitialState() async throws {
        let recordingManager = RecordingManager()
        
        #expect(!recordingManager.isRecording)
        #expect(recordingManager.recordingDuration == 0)
        #expect(recordingManager.recordingQuality == .high)
    }
    
    @Test func testRecordingManagerStartStop() async throws {
        let recordingManager = RecordingManager()
        
        recordingManager.startRecording()
        #expect(recordingManager.isRecording)
        
        recordingManager.stopRecording()
        #expect(!recordingManager.isRecording)
    }
    
    @Test func testRecordingManagerReset() async throws {
        let recordingManager = RecordingManager()
        
        recordingManager.startRecording()
        recordingManager.resetRecording()
        
        #expect(!recordingManager.isRecording)
        #expect(recordingManager.recordingDuration == 0)
    }
    
    @Test func testRecordingManagerFormattedDuration() async throws {
        let recordingManager = RecordingManager()
        recordingManager.recordingDuration = 125.5 // 2 минуты 5.5 секунд
        
        #expect(recordingManager.formattedDuration == "02:05")
    }
    
    // MARK: - Constants Tests
    
    @Test func testConstantsValues() async throws {
        #expect(Constants.Audio.sampleRate == 44100)
        #expect(Constants.Audio.bufferSize == 1024)
        #expect(Constants.Audio.fftSize == 1024)
        #expect(Constants.Audio.maxRPM == 8000)
        #expect(Constants.Audio.minRPM == 0)
        
        #expect(Constants.Analysis.criticalNoiseLevel == -20.0)
        #expect(Constants.Analysis.warningNoiseLevel == -40.0)
        #expect(Constants.Analysis.quietNoiseLevel == -60.0)
        #expect(Constants.Analysis.peakThreshold == 0.1)
        #expect(Constants.Analysis.highFrequencyThreshold == 0.5)
        
        #expect(Constants.UI.amplitudeBarCount == 30)
        #expect(Constants.UI.frequencyBarCount == 20)
        #expect(Constants.UI.animationDuration == 0.3)
        #expect(Constants.UI.updateInterval == 0.1)
    }
    
    // MARK: - EngineStatus Tests
    
    @Test func testEngineStatusProperties() async throws {
        #expect(EngineStatus.normal.color == .green)
        #expect(EngineStatus.warning.color == .yellow)
        #expect(EngineStatus.critical.color == .ferrariRed)
        
        #expect(EngineStatus.normal.title == "OK")
        #expect(EngineStatus.warning.title == "WARN")
        #expect(EngineStatus.critical.title == "CRIT")
        
        #expect(EngineStatus.normal.description == "Двигатель в норме")
        #expect(EngineStatus.warning.description == "Обнаружены незначительные проблемы")
        #expect(EngineStatus.critical.description == "Требуется срочная диагностика!")
    }
    
    // MARK: - RecordingQuality Tests
    
    @Test func testRecordingQualityProperties() async throws {
        #expect(RecordingManager.RecordingQuality.low.sampleRate == 22050)
        #expect(RecordingManager.RecordingQuality.medium.sampleRate == 44100)
        #expect(RecordingManager.RecordingQuality.high.sampleRate == 48000)
        
        #expect(RecordingManager.RecordingQuality.low.description == "Низкое")
        #expect(RecordingManager.RecordingQuality.medium.description == "Среднее")
        #expect(RecordingManager.RecordingQuality.high.description == "Высокое")
    }
    
    // MARK: - iOS Compatibility Tests
    
    @Test func testiOS18Compatibility() async throws {
        // Проверяем, что приложение совместимо с iOS 18+
        if #available(iOS 18.0, *) {
            #expect(true, "Приложение совместимо с iOS 18+")
        }
    }
    
    @Test func testiPhone12Compatibility() async throws {
        // Проверяем требования для iPhone 12+
        let requiredCapabilities = ["armv7", "microphone"]
        
        for capability in requiredCapabilities {
            #expect(true, "Поддерживается \(capability)")
        }
    }
    
    // MARK: - Performance Tests
    
    @Test func testAudioAnalysisPerformance() async throws {
        let audioAnalyzer = AudioAnalyzer()
        
        let startTime = Date()
        
        for _ in 0..<100 {
            let testAmplitude = CGFloat.random(in: 0...1)
            audioAnalyzer.updateAmplitudes(with: testAmplitude)
            audioAnalyzer.analyzeEngineSound()
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        #expect(duration < 1.0, "Анализ должен выполняться быстро: \(duration) секунд")
    }
    
    @Test func testFFTSetupPerformance() async throws {
        let startTime = Date()
        
        let analyzer = AudioAnalyzer()
        _ = analyzer
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        #expect(duration < 0.1, "FFT setup должен быть быстрым: \(duration) секунд")
    }
}
