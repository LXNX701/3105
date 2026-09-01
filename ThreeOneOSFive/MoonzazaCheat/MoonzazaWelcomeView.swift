import SwiftUI

struct MoonzazaWelcomeView: View {
    @EnvironmentObject var authStore: MoonzazaAuthStore
    @State private var onlineUsers = 0
    @State private var appVersion = "v1.0"
    
    var body: some View {
        ZStack {
            MZColor.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [MZColor.accentRed, MZColor.accentMagenta], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: MZColor.accentRed.opacity(0.6), radius: 30)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: 1.2)
                
                Text("WELCOME")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(authStore.session?.username ?? "User")
                    .font(.title2)
                    .foregroundColor(MZColor.accentPurple)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("\(onlineUsers)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(MZColor.neonGreen)
                        Text("ONLINE")
                            .font(.caption)
                            .foregroundColor(MZColor.textMuted)
                    }
                    VStack {
                        Text(appVersion)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(MZColor.accentPurple)
                        Text("VERSION")
                            .font(.caption)
                            .foregroundColor(MZColor.textMuted)
                    }
                }
                .padding()
                .glassmorphism()
            }
            .padding()
        }
        .task {
            let service = KeyAuthService()
            await service.fetchStats()
            onlineUsers = service.onlineUsers
            appVersion = KeyAuthConfig.appVersion
        }
    }
}