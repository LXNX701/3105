import SwiftUI

struct MoonzazaRootView: View {
    @StateObject private var authStore = MoonzazaAuthStore()
    @StateObject private var patchManager = MoonzazaPatchManager()
    
    var body: some View {
        Group {
            if !authStore.isAuthenticated {
                MoonzazaLoginView()
                    .environmentObject(authStore)
            } else if authStore.showWelcome {
                MoonzazaWelcomeView()
                    .environmentObject(authStore)
                    .transition(.opacity)
            } else {
                MoonzazaDashboardView()
                    .environmentObject(authStore)
                    .environmentObject(patchManager)
            }
        }
        .animation(.easeInOut, value: authStore.isAuthenticated)
        .animation(.easeInOut, value: authStore.showWelcome)
    }
}