import AVFoundation
import Combine

class PermissionManager: ObservableObject {
    @Published var showPermissionAlert = false
    @Published var permissionStatus: PermissionStatus = .notDetermined
    
    enum PermissionStatus {
        case notDetermined
        case granted
        case denied
    }
    
    init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionStatus = .granted
        case .denied:
            permissionStatus = .denied
        case .undetermined:
            permissionStatus = .notDetermined
        @unknown default:
            permissionStatus = .notDetermined
        }
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 18.0, *) {
            Task {
                let granted = await iOSCompatibility.requestMicrophonePermission()
                await MainActor.run {
                    self.permissionStatus = granted ? .granted : .denied
                    if granted {
                        completion(true)
                    } else {
                        self.showPermissionAlert = true
                        completion(false)
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.permissionStatus = granted ? .granted : .denied
                    if granted {
                        completion(true)
                    } else {
                        self.showPermissionAlert = true
                        completion(false)
                    }
                }
            }
        }
    }
}
