import SwiftUI
import AVFoundation

struct AnalyzerView: View {
    @ObservedObject var audioAnalyzer: AudioAnalyzer
    @ObservedObject var permissionManager: PermissionManager
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var historyStore: HistoryStore
    @Environment(\.colorScheme) var colorScheme
    
    private let entranceAnimation = Animation.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2)
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.ferrariDarkBackground : Color.ferrariIvory
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.ferrariDarkText : Color.ferrariDark
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.ferrariDarkSurface : Color.white
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            // Частицы при критическом статусе
            if audioAnalyzer.displayedEngineStatus == .critical && audioAnalyzer.isRecording {
                ParticleEffect(isActive: true)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "horse")
                            .font(.system(size: 50))
                            .foregroundColor(.ferrariRed)
                            .padding(.bottom, 5)
                        
                        Text("ENGINE WHISPERER")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                            .tracking(2)
                            .contentTransition(.opacity)
                    }
                    .padding(.top, 30)
                    .scaleEffect(audioAnalyzer.isRecording ? 0.97 : 1.0)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
                    VStack {
                        Text(audioAnalyzer.displayedEngineStatus.description)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 56)
                            .contentTransition(.opacity)
                        
                        StatusIndicator(status: audioAnalyzer.displayedEngineStatus)
                            .padding(.top, 10)
                    }
                    .opacity(audioAnalyzer.isRecording ? 1 : 1)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
                    if audioAnalyzer.isRecording {
                        SoundVisualizer(levels: audioAnalyzer.amplitudes)
                            .frame(height: 160)
                            .padding(.horizontal, 20)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    RecordingButton(
                        isRecording: audioAnalyzer.isRecording,
                        action: {
                            handleRecordingAction()
                        }
                    )
                    .padding(.vertical, 30)
                    .scaleEffect(audioAnalyzer.isRecording ? 0.98 : 1.0)
                    .animation(entranceAnimation, value: audioAnalyzer.isRecording)
                    
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
                    
                    if !audioAnalyzer.isRecording && !audioAnalyzer.history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("История анализа (текущая сессия)")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
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
                    // Останавливаем запись и сохраняем сессию в историю
                    audioAnalyzer.toggleRecording()
                    recordingManager.stopRecording()
                    
                    let session = EngineSession(
                        id: UUID(),
                        date: Date(),
                        duration: recordingManager.recordingDuration,
                        finalStatus: audioAnalyzer.displayedEngineStatus,
                        statuses: audioAnalyzer.history
                    )
                    historyStore.addSession(session)
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



