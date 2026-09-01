import SwiftUI

// MARK: - Colors
enum MZColor {
    static let background = Color(hex: "0A0A0F")
    static let surface = Color(white: 0.08).opacity(0.9)
    static let accentRed = Color(hex: "FF1744")
    static let accentPurple = Color(hex: "9C27B0")
    static let accentMagenta = Color(hex: "E040FB")
    static let accentGold = Color(hex: "FFB300")
    static let neonGreen = Color(hex: "00E676")
    static let textPrimary = Color.white
    static let textMuted = Color(white: 0.55)
    static let glassBorder = Color(white: 0.2).opacity(0.5)
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphismCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(white: 0.12).opacity(0.6))
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MZColor.glassBorder, lineWidth: 1)
                        .blur(radius: 0.5)
                }
            )
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassmorphism() -> some View {
        modifier(GlassmorphismCard())
    }
}

// MARK: - Neon Border (Animated RGB)
struct NeonBorderModifier: ViewModifier {
    @State private var hueRotation = 0.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .purple, .blue, .cyan, .red]),
                            center: .center,
                            angle: .degrees(hueRotation)
                        ),
                        lineWidth: 2
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            hueRotation = 360
                        }
                    }
            )
    }
}

extension View {
    func neonBorder() -> some View {
        modifier(NeonBorderModifier())
    }
}

// MARK: - Pulse Effect
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPulsing)
            .onTapGesture {
                isPulsing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPulsing = false
                }
            }
    }
}

extension View {
    func pulseOnTap() -> some View {
        modifier(PulseEffect())
    }
}