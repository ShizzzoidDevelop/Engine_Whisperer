import SwiftUI

struct RecordingButton: View {
    let isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.ferrariRed : Color.ferrariDark)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(isRecording ? Color.ferrariRed : Color.ferrariDark, lineWidth: 4)
                    )
                
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.ferrariIvory)
            }
            .scaleEffect(isRecording ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isRecording)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityIdentifier("RecordingButton")
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
