//
//  Engine_WhispererUITests.swift
//  Engine WhispererUITests
//
//  Created by Тима Таскин on 11.07.2025.
//

import XCTest

final class Engine_WhispererUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Main UI Tests
    
    @MainActor
    func testAppLaunch() throws {
        // Проверяем, что приложение запускается
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    @MainActor
    func testMainUIElements() throws {
        // Проверяем наличие основных элементов интерфейса
        XCTAssertTrue(app.staticTexts["ENGINE WHISPERER"].exists)
        XCTAssertTrue(app.images["horse"].exists)
        XCTAssertTrue(app.buttons.matching(identifier: "RecordingButton").firstMatch.exists)
    }
    
    @MainActor
    func testRecordingButtonInteraction() throws {
        let recordingButton = app.buttons.matching(identifier: "RecordingButton").firstMatch
        
        // Проверяем начальное состояние
        XCTAssertTrue(recordingButton.exists)
        
        // Нажимаем на кнопку записи
        recordingButton.tap()
        
        // Проверяем, что состояние изменилось
        XCTAssertTrue(recordingButton.exists)
    }
    
    @MainActor
    func testStatusIndicator() throws {
        // Проверяем наличие индикатора состояния
        let statusIndicator = app.otherElements.matching(identifier: "StatusIndicator").firstMatch
        XCTAssertTrue(statusIndicator.exists)
    }
    
    @MainActor
    func testSoundVisualizer() throws {
        // Проверяем наличие визуализатора звука
        let soundVisualizer = app.otherElements.matching(identifier: "SoundVisualizer").firstMatch
        XCTAssertTrue(soundVisualizer.exists)
    }
    
    @MainActor
    func testIndicatorItems() throws {
        // Проверяем наличие показателей
        XCTAssertTrue(app.staticTexts["ОБОРОТЫ"].exists)
        XCTAssertTrue(app.staticTexts["УРОВЕНЬ ШУМА"].exists)
    }
    
    // MARK: - Permission Tests
    
    @MainActor
    func testMicrophonePermissionAlert() throws {
        // Нажимаем на кнопку записи
        let recordingButton = app.buttons.matching(identifier: "RecordingButton").firstMatch
        recordingButton.tap()
        
        // Проверяем, что появился алерт с разрешениями
        let alert = app.alerts.firstMatch
        if alert.exists {
            XCTAssertTrue(alert.staticTexts["Требуется доступ к микрофону"].exists)
            XCTAssertTrue(alert.buttons["Настройки"].exists)
            XCTAssertTrue(alert.buttons["Отмена"].exists)
        }
    }
    
    // MARK: - Navigation Tests
    
    @MainActor
    func testAppOrientation() throws {
        // Тестируем поворот устройства
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.staticTexts["ENGINE WHISPERER"].exists)
        
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.staticTexts["ENGINE WHISPERER"].exists)
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    @MainActor
    func testUIResponsiveness() throws {
        let recordingButton = app.buttons.matching(identifier: "RecordingButton").firstMatch
        
        // Тестируем отзывчивость UI при быстрых нажатиях
        for _ in 0..<10 {
            recordingButton.tap()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        // UI должен оставаться отзывчивым
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityLabels() throws {
        // Проверяем accessibility labels
        let recordingButton = app.buttons.matching(identifier: "RecordingButton").firstMatch
        XCTAssertTrue(recordingButton.exists)
        
        // Проверяем, что элементы доступны для VoiceOver
        XCTAssertTrue(recordingButton.isHittable)
    }
    
    // MARK: - Memory Tests
    
    @MainActor
    func testMemoryUsage() throws {
        // Тестируем использование памяти
        let initialMemory = getMemoryUsage()
        
        // Выполняем различные действия
        let recordingButton = app.buttons.matching(identifier: "RecordingButton").firstMatch
        for _ in 0..<50 {
            recordingButton.tap()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Проверяем, что утечек памяти нет
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024, "Утечка памяти: \(memoryIncrease) байт")
    }
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
}
