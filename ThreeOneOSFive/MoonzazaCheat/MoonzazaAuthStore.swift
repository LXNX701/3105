import Foundation
import SwiftUI

@MainActor
class MoonzazaAuthStore: ObservableObject {
    @Published var isAuthenticated = false
    @Published var session: KeyAuthSession?
    @Published var showWelcome = false
    
    private let sessionKey = "moonzaza.session"
    private let defaults = UserDefaults.standard
    
    init() {
        loadSession()
    }
    
    func login(session: KeyAuthSession) {
        self.session = session
        self.isAuthenticated = true
        self.showWelcome = true
        saveSession()
        
        // Show welcome for 1.5s then transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.showWelcome = false
            }
        }
    }
    
    func logout() {
        session = nil
        isAuthenticated = false
        showWelcome = false
        defaults.removeObject(forKey: sessionKey)
    }
    
    private func saveSession() {
        guard let session = session else { return }
        if let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: sessionKey)
        }
    }
    
    private func loadSession() {
        guard let data = defaults.data(forKey: sessionKey),
              let session = try? JSONDecoder().decode(KeyAuthSession.self, from: data) else {
            return
        }
        self.session = session
        self.isAuthenticated = true
    }
}