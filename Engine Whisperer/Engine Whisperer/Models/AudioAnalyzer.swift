import AVFoundation
import Combine
import Accelerate

class AudioAnalyzer: ObservableObject {
    @Published var isRecording = false
    @Published var amplitudes: [CGFloat] = Array(repeating: 0, count: Constants.UI.amplitudeBarCount)
    @Published var noiseLevel: Float = 0
    @Published var rpm: Int = 0
    @Published var engineStatus: EngineStatus = .normal
    @Published var statusDescription = "Проверка не проводилась"
    @Published var frequencyData: [Float] = Array(repeating: 0, count: Constants.UI.frequencyBarCount)
    @Published var history: [EngineStatus] = []
    @Published var historyTimestamps: [Date] = []
    // Отдельные поля для более медленного UI
    @Published var displayedEngineStatus: EngineStatus = .normal
    @Published var displayedStatusDescription: String = "Проверка не проводилась"
    
    // Аудио компоненты
    private var audioEngine: AVAudioEngine?
    private let audioSession = AVAudioSession.sharedInstance()
    private var cancellables = Set<AnyCancellable>()
    
    // Для FFT анализа
    private var fftSetup: FFTSetup?
    private var fftBufferSize: Int = 1024
    private var fftBuffer: [Float] = []
    private var window: [Float] = []
    
    // Для анализа RPM
    private var peakFrequencies: [Float] = []
    private var lastAnalysisTime: Date = Date()
    
    // Для троттлинга UI
    private var lastUIDisplayUpdate: Date = Date.distantPast
    private let uiUpdateMinInterval: TimeInterval = 0.7
    
    init() {
        setupFFT()
    }
    
    deinit {
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }
    
    private func setupFFT() {
        fftBufferSize = Constants.Audio.fftSize
        fftBuffer = Array(repeating: 0, count: fftBufferSize)
        
        // Создаем окно Ханна для уменьшения спектральных искажений
        window = createHannWindow(count: fftBufferSize)
        
        // Настраиваем FFT
        let log2n = vDSP_Length(log2(Double(fftBufferSize)))
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
    }
    
    private func createHannWindow(count: Int) -> [Float] {
        var window = [Float](repeating: 0, count: count)
        for i in 0..<count {
            let angle = 2.0 * Double.pi * Double(i) / Double(count - 1)
            window[i] = Float(0.5 * (1.0 - cos(angle)))
        }
        return window
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Очищаем историю текущей сессии
        history.removeAll(keepingCapacity: true)
        historyTimestamps.removeAll(keepingCapacity: true)
        
        // Проверяем доступность аудиосессии
        guard AVAudioSession.sharedInstance().isInputAvailable else {
            statusDescription = Constants.Messages.microphoneUnavailable
            return
        }
        
        // Проверяем разрешения
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
            statusDescription = Constants.Messages.noPermission
            return
        }
        
        isRecording = true
        statusDescription = Constants.Messages.engineAnalysisInProgress
        displayedStatusDescription = Constants.Messages.engineAnalysisInProgress
        displayedEngineStatus = engineStatus
        
        // Настраиваем аудиосессию с совместимостью для iOS 18+
        do {
            let session = audioSession
            if #available(iOS 18.0, *) {
                // Безопасная запись только входа
                do {
                    try session.setCategory(.record, mode: .measurement, options: [])
                } catch {
                    // Фолбэк на .playAndRecord без маршрутизации на динамик
                    try session.setCategory(.playAndRecord, mode: .measurement, options: [])
                }
            } else {
                // На iOS < 18 избегаем .defaultToSpeaker — конфликтует с .measurement
                try session.setCategory(.record, mode: .measurement, options: [])
            }
            // Необязательные предпочтения — если не поддерживаются, продолжаем
            try? session.setPreferredSampleRate(Constants.Audio.sampleRate)
            try? session.setPreferredIOBufferDuration(0.005)
            try? session.setPreferredInputNumberOfChannels(1)
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
            statusDescription = "\(Constants.Messages.audioSetupError): \(error.localizedDescription)"
            isRecording = false
            return
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { 
            statusDescription = "Ошибка создания аудио движка"
            isRecording = false
            return 
        }
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        
        // Устанавливаем тап для анализа аудио
        inputNode.installTap(onBus: 0, bufferSize: UInt32(Constants.Audio.bufferSize), format: format) { buffer, _ in
            DispatchQueue.main.async {
                self.processAudioBuffer(buffer)
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
            statusDescription = "Ошибка запуска: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    private func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        isRecording = false
        statusDescription = Constants.Messages.analysisComplete
        displayedStatusDescription = Constants.Messages.analysisComplete
        
        // Деактивируем аудиосессию
        do {
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frames = buffer.frameLength
        
        // Копируем данные в буфер
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: Int(frames)))
        
        // Рассчет RMS (Root Mean Square) для уровня шума
        var rms: Float = 0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(frames))

        // Пиковая амплитуда для живой реакции визуализатора
        var maxAbs: Float = 0
        vDSP_maxmgv(samples, 1, &maxAbs, vDSP_Length(frames))

        // Конвертация в dB
        let dB: Float = rms > 0 ? 20 * log10(rms) : -160

        // Масштабируем пиковую амплитуду (клипуем для стабильности UI)
        let peakScaled: Float = min(maxAbs * 80.0, 3.0)
        let amplitude = CGFloat(peakScaled)
        
        // Выполняем FFT анализ для частотного анализа
        performFFTAnalysis(samples: samples)
        
        DispatchQueue.main.async {
            self.noiseLevel = dB
            self.updateAmplitudes(with: amplitude)
            self.analyzeEngineSound()
        }
    }
    
    private func performFFTAnalysis(samples: [Float]) {
        guard samples.count >= fftBufferSize else { return }
        
        // Берем первые fftBufferSize сэмплов
        let inputSamples = Array(samples.prefix(fftBufferSize))
        
        // Применяем окно Ханна
        var windowedSamples = [Float](repeating: 0, count: fftBufferSize)
        vDSP_vmul(inputSamples, 1, window, 1, &windowedSamples, 1, vDSP_Length(fftBufferSize))
        
        // Подготавливаем данные для FFT
        var realParts = [Float](repeating: 0, count: fftBufferSize/2)
        var imagParts = [Float](repeating: 0, count: fftBufferSize/2)
        
        // Выполняем FFT
        var splitComplex = DSPSplitComplex(realp: &realParts, imagp: &imagParts)
        
        // Преобразуем данные для FFT
        let samplesPointer = windowedSamples.withUnsafeMutableBufferPointer { bufferPointer in
            return bufferPointer.baseAddress!
        }
        
        vDSP_ctoz(UnsafePointer<DSPComplex>(OpaquePointer(samplesPointer)), 2, &splitComplex, 1, vDSP_Length(fftBufferSize/2))
        
        guard let fftSetup = fftSetup else { return }
        vDSP_fft_zrip(fftSetup, &splitComplex, 1, vDSP_Length(log2(Double(fftBufferSize))), Int32(FFT_FORWARD))
        
        // Вычисляем магнитуды
        var magnitudes = [Float](repeating: 0, count: fftBufferSize/2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftBufferSize/2))
        
        // Обновляем частотные данные
        DispatchQueue.main.async {
            self.updateFrequencyData(magnitudes: magnitudes)
        }
    }
    
    private func updateFrequencyData(magnitudes: [Float]) {
        // Берем только первые 20 частотных компонентов для отображения
        let displayCount = min(20, magnitudes.count)
        frequencyData = Array(magnitudes.prefix(displayCount))
        
        // Анализируем пиковые частоты для определения RPM
        analyzePeakFrequencies(magnitudes: magnitudes)
    }
    
    private func analyzePeakFrequencies(magnitudes: [Float]) {
        // Ищем пиковые частоты (упрощенный алгоритм)
        let threshold: Float = Constants.Analysis.peakThreshold
        var peaks: [Float] = []
        
        for i in 1..<magnitudes.count-1 {
            if magnitudes[i] > threshold && 
               magnitudes[i] > magnitudes[i-1] && 
               magnitudes[i] > magnitudes[i+1] {
                peaks.append(Float(i))
            }
        }
        
        // Обновляем пиковые частоты
        peakFrequencies = peaks
        
        // Простая оценка RPM на основе доминирующей частоты
        if let dominantPeak = peaks.max() {
            let peakBin: Float = dominantPeak
            let sampleRateF: Float = Float(Constants.Audio.sampleRate)
            let fftSizeF: Float = Float(fftBufferSize)
            let binFrequency: Float = sampleRateF / fftSizeF
            let fundamentalHz: Float = peakBin * binFrequency
            let rpmFloat: Float = fundamentalHz * 60.0
            let estimatedRPM: Int = Int(rpmFloat)
            rpm = max(Constants.Audio.minRPM, min(Constants.Audio.maxRPM, estimatedRPM))
        }
    }
    
    private func updateAmplitudes(with value: CGFloat) {
        amplitudes.removeFirst()
        amplitudes.append(value)
    }
    
    private func analyzeEngineSound() {
        let maxAmplitude = amplitudes.max() ?? 0
        let avgNoiseLevel = noiseLevel
        
        // Обновляем «истинный» статус мгновенно
        if avgNoiseLevel > Constants.Analysis.criticalNoiseLevel {
            engineStatus = .critical
            statusDescription = "Критический уровень шума - возможна детонация"
        } else if avgNoiseLevel > Constants.Analysis.warningNoiseLevel && maxAmplitude > 1.0 {
            engineStatus = .warning
            statusDescription = "Обнаружены аномалии в работе двигателя"
        } else if avgNoiseLevel < Constants.Analysis.quietNoiseLevel {
            engineStatus = .normal
            statusDescription = "Двигатель работает тихо и стабильно"
        } else {
            engineStatus = .normal
            statusDescription = "Двигатель работает нормально"
        }
        
        // Дополнительный анализ на основе частотных характеристик
        if let maxFreq = frequencyData.max() {
            if maxFreq > Constants.Analysis.highFrequencyThreshold {
                if engineStatus == .normal {
                    statusDescription += " - обнаружены высокочастотные компоненты"
                    engineStatus = .warning
                }
            }
        }
        
        // Пишем «историю» каждый кадр во время записи
        if isRecording {
            history.append(engineStatus)
            historyTimestamps.append(Date())
        }
        
        // Обновляем «отображаемый» статус с троттлингом
        maybeUpdateDisplayedStatus()
    }
    
    private func maybeUpdateDisplayedStatus() {
        let now = Date()
        let timeSince = now.timeIntervalSince(lastUIDisplayUpdate)
        // Разрешаем немедленное обновление при усилении критичности
        let isEscalation = (displayedEngineStatus == .normal && (engineStatus == .warning || engineStatus == .critical)) ||
                           (displayedEngineStatus == .warning && engineStatus == .critical)
        if isEscalation || timeSince >= uiUpdateMinInterval {
            displayedEngineStatus = engineStatus
            displayedStatusDescription = statusDescription
            lastUIDisplayUpdate = now
        }
    }
    
    // Симуляция данных двигателя для демонстрации (только когда не записываем)
    private func simulateEngineData() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard !self.isRecording else { return }
                let randomAmplitude = CGFloat.random(in: 0.1...0.8)
                self.updateAmplitudes(with: randomAmplitude)
                
                // Симуляция RPM
                self.rpm = Int.random(in: 800...1500)
            }
            .store(in: &cancellables)
    }
}
