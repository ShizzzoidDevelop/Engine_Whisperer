import SwiftUI
import AVFoundation

// Расширение для цветов Ferrari
extension Color {
    static let ferrariRed = Constants.Colors.ferrariRed
    static let ferrariIvory = Constants.Colors.ferrariIvory
    static let ferrariDark = Constants.Colors.ferrariDark
}

struct ContentView: View {
    @StateObject private var audioAnalyzer = AudioAnalyzer()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var recordingManager = RecordingManager()
    
    private let entranceAnimation = Animation.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2)
    
    var body: some View {
        ZStack {
            // Фон цвета слоновой кости Ferrari
            Color.ferrariIvory
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Заголовок с лошадью Ferrari
                    VStack {
                        Image(systemName: "horse")
                            .font(.system(size: 50))
                            .foregroundColor(.ferrariRed)
                            .padding(.bottom, 5)
                        
                        Text("ENGINE WHISPERER")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.ferrariDark)
                            .tracking(2)
                            .contentTransition(.opacity)
                    }
                    .padding(.top, 30)
                    .scaleEffect(audioAnalyzer.isRecording ? 0.97 : 1.0)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
                    // Индикатор состояния
                    VStack {
                        Text(audioAnalyzer.displayedEngineStatus.description)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.ferrariDark)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 56)
                            .contentTransition(.opacity)
                        
                        StatusIndicator(status: audioAnalyzer.displayedEngineStatus)
                            .padding(.top, 10)
                    }
                    .opacity(audioAnalyzer.isRecording ? 1 : 1)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
                    // Визуализатор звука (объединенный эквалайзер)
                    if audioAnalyzer.isRecording {
                        SoundVisualizer(levels: audioAnalyzer.amplitudes)
                            .frame(height: 160)
                            .padding(.horizontal, 20)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Кнопка записи
                    RecordingButton(
                        isRecording: audioAnalyzer.isRecording,
                        action: {
                            handleRecordingAction()
                        }
                    )
                    .padding(.vertical, 30)
                    .scaleEffect(audioAnalyzer.isRecording ? 0.98 : 1.0)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
                    // Панель показателей (только во время записи)
                    if audioAnalyzer.isRecording {
                        VStack(spacing: 15) {
                            IndicatorItem(
                                icon: "speedometer",
                                title: "ОБОРОТЫ",
                                value: "\(audioAnalyzer.rpm) RPM",
                                color: .ferrariRed
                            )
                            
                            IndicatorItem(
                                icon: "waveform.path",
                                title: "УРОВЕНЬ ШУМА",
                                value: String(format: "%.1f dB", audioAnalyzer.noiseLevel),
                                color: .ferrariRed
                            )
                            
                            IndicatorItem(
                                icon: "clock",
                                title: "ВРЕМЯ ЗАПИСИ",
                                value: recordingManager.formattedDuration,
                                color: .ferrariRed
                            )
                        }
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    // История статусов после записи
                    if !audioAnalyzer.isRecording && !audioAnalyzer.history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("История анализа")
                                .font(.headline)
                                .foregroundColor(.ferrariDark)
                            
                            StatusTimeline(statuses: audioAnalyzer.history)
                                .frame(height: 14)
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            checkInitialPermissions()
            iOSCompatibility.optimizeForDevice()
            ProjectSettings.configureForDevice()
            ProjectSettings.configureForiOSVersion()
        }
        .alert(isPresented: $permissionManager.showPermissionAlert) {
            Alert(
                title: Text("Требуется доступ к микрофону"),
                message: Text("Для анализа двигателя необходимо разрешение на использование микрофона"),
                primaryButton: .default(Text("Настройки")) {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsUrl)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func checkInitialPermissions() {
        permissionManager.checkPermissionStatus()
    }
    
    private func handleRecordingAction() {
        switch permissionManager.permissionStatus {
        case .granted:
            withAnimation(entranceAnimation) {
                if audioAnalyzer.isRecording {
                    audioAnalyzer.toggleRecording()
                    recordingManager.stopRecording()
                } else {
                    audioAnalyzer.toggleRecording()
                    recordingManager.startRecording()
                }
            }
        case .denied:
            permissionManager.showPermissionAlert = true
        case .notDetermined:
            permissionManager.requestMicrophonePermission { granted in
                if granted {
                    withAnimation(entranceAnimation) {
                        audioAnalyzer.toggleRecording()
                        recordingManager.startRecording()
                    }
                }
            }
        }
    }
}

// Компонент для показателей
struct IndicatorItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.ferrariDark.opacity(0.7))
                    .tracking(1)
                    .contentTransition(.opacity)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.ferrariDark)
                    .contentTransition(.numericText())
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
