import SwiftUI

struct ParticleEffect: View {
    let isActive: Bool
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var opacity: Double
        var size: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.ferrariRed.opacity(particle.opacity),
                                    Color.red.opacity(particle.opacity * 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: particle.size * 0.3)
                }
            }
            .onAppear {
                if isActive {
                    startParticles(in: geometry.size)
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    startParticles(in: geometry.size)
                } else {
                    particles.removeAll()
                }
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }
    
    private func startParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: size.width * 0.2...size.width * 0.8),
                    y: CGFloat.random(in: size.height * 0.2...size.height * 0.8)
                ),
                velocity: CGVector(
                    dx: CGFloat.random(in: (-2)...2),
                    dy: CGFloat.random(in: (-3)...(-1))
                ),
                opacity: Double.random(in: 0.3...0.8),
                size: CGFloat.random(in: 4...12)
            )
        }
    }
    
    private func updateParticles(in size: CGSize) {
        guard isActive else { return }
        
        for index in particles.indices {
            particles[index].position.x += particles[index].velocity.dx
            particles[index].position.y += particles[index].velocity.dy
            
            // Добавляем гравитацию
            particles[index].velocity.dy += 0.1
            
            // Уменьшаем непрозрачность со временем
            particles[index].opacity -= 0.02
            
            // Если частица вышла за границы или стала невидимой, пересоздаем её
            if particles[index].position.y > size.height ||
               particles[index].position.x < 0 ||
               particles[index].position.x > size.width ||
               particles[index].opacity <= 0 {
                particles[index] = Particle(
                    position: CGPoint(
                        x: CGFloat.random(in: size.width * 0.2...size.width * 0.8),
                        y: CGFloat.random(in: 0...size.height * 0.3)
                    ),
                    velocity: CGVector(
                        dx: CGFloat.random(in: (-2)...2),
                        dy: CGFloat.random(in: (-3)...(-1))
                    ),
                    opacity: Double.random(in: 0.5...0.9),
                    size: CGFloat.random(in: 4...12)
                )
            }
        }
    }
}
