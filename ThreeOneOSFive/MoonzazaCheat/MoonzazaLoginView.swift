import SwiftUI

struct MoonzazaLoginView: View {
    @EnvironmentObject var authStore: MoonzazaAuthStore
    @StateObject private var keyAuth = KeyAuthService()
    
    @State private var username = ""
    @State private var password = ""
    @State private var licenseKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Fondo
            MZColor.background.ignoresSafeArea()
            
            // Partículas
            MoonzazaParticleView()
                .ignoresSafeArea()
            
            // Contenido
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 40)
                    
                    // Logo / Título
                    VStack(spacing: 5) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(colors: [MZColor.accentRed, MZColor.accentPurple], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: MZColor.accentRed.opacity(0.5), radius: 20)
                        
                        Text("MOONZAZA")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        +
                        Text(" X CHEAT")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(MZColor.accentRed)
                        
                        Text("PATCH CONTROL CENTER")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(MZColor.accentPurple)
                            .tracking(2)
                    }
                    .padding(.bottom, 10)
                    
                    // Formulario
                    VStack(spacing: 16) {
                        GlassInputField(placeholder: "Username", text: $username, icon: "person")
                        GlassInputField(placeholder: "Password", text: $password, icon: "lock", isSecure: true)
                        GlassInputField(placeholder: "License Key", text: $licenseKey, icon: "key")
                    }
                    .padding(.horizontal)
                    
                    // Botón Login
                    Button {
                        Task { await performLogin() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .padding(.trailing, 5)
                            }
                            Text(isLoading ? "AUTHENTICATING..." : "LOGIN")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(colors: [MZColor.accentRed, MZColor.accentMagenta], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: MZColor.accentRed.opacity(0.4), radius: 15)
                        .pulseOnTap()
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    
                    // Mensaje de error
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Pie de página
                    Text("v\(KeyAuthConfig.appVersion) • Secure Connection")
                        .font(.caption)
                        .foregroundColor(MZColor.textMuted)
                }
                .padding()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        })
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await keyAuth.login(username: username, password: password, licenseKey: licenseKey)
            await MainActor.run {
                authStore.login(session: session)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
}

// MARK: - Glass Input Field
struct GlassInputField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(MZColor.accentPurple)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MZColor.glassBorder, lineWidth: 1)
                )
        )
    }
}