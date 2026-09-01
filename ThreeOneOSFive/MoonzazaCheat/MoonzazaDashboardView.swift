import SwiftUI

struct MoonzazaDashboardView: View {
    @EnvironmentObject var authStore: MoonzazaAuthStore
    @StateObject private var patchManager = MoonzazaPatchManager()
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isApplying = false
    @State private var isRestoring = false
    @State private var toastMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("WELCOME BACK,")
                                .font(.caption)
                                .foregroundColor(MZColor.textMuted)
                            Text(authStore.session?.username ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button {
                            authStore.logout()
                        } label: {
                            Image(systemName: "door.right.hand.open")
                                .font(.title2)
                                .foregroundColor(MZColor.accentRed)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 15) {
                        StatChip(label: "ONLINE", value: "\(authStore.session?.onlineUsers ?? 0)", color: MZColor.neonGreen)
                        StatChip(label: "VERSION", value: "v\(KeyAuthConfig.appVersion)", color: MZColor.accentPurple)
                        StatChip(label: "STATUS", value: "ACTIVE", color: MZColor.neonGreen)
                    }
                    .padding(.horizontal)
                    
                    // Target Selector
                    Picker("Target", selection: $patchManager.targetApp) {
                        Text("FF NORMAL").tag(FreefirePatch.TargetApp.normal)
                        Text("FF MAX").tag(FreefirePatch.TargetApp.max)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .tint(MZColor.accentPurple)
                    
                    // Patches Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FREE FIRE PATCHES")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach($patchManager.patches) { $patch in
                                MoonzazaPatchCard(patch: $patch)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            Task { await applyPatches() }
                        } label: {
                            HStack {
                                if isApplying {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .padding(.trailing, 5)
                                }
                                Text(isApplying ? "APPLYING..." : "⚡ APPLY PATCHES")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(colors: [MZColor.accentRed, MZColor.accentMagenta], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: MZColor.accentRed.opacity(0.3), radius: 10)
                        }
                        .disabled(isApplying)
                        
                        Button {
                            Task { await restoreOriginals() }
                        } label: {
                            HStack {
                                if isRestoring {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 5)
                                }
                                Text(isRestoring ? "RESTORING..." : "🔄 RESTORE ORIGINAL")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(MZColor.accentPurple.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: MZColor.accentPurple.opacity(0.3), radius: 10)
                        }
                        .disabled(isRestoring)
                    }
                    .padding(.horizontal)
                    
                    // Launch Buttons
                    HStack(spacing: 12) {
                        Button {
                            patchManager.launchApp("com.dts.freefire")
                        } label: {
                            Text("🎮 LAUNCH FF")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(MZColor.accentGold.opacity(0.8))
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        Button {
                            patchManager.launchApp("com.dts.freefiremax")
                        } label: {
                            Text("🎮 LAUNCH FF MAX")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(MZColor.accentGold.opacity(0.8))
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(MZColor.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .toast(message: toastMessage, isPresented: .constant(toastMessage != nil))
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func applyPatches() async {
        isApplying = true
        do {
            try await patchManager.applyPatches()
            toastMessage = "✅ Patches applied successfully!"
        } catch {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
        isApplying = false
    }
    
    private func restoreOriginals() async {
        isRestoring = true
        do {
            try await patchManager.restoreOriginals()
            toastMessage = "✅ Originals restored!"
        } catch {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
        isRestoring = false
    }
}

// MARK: - Stat Chip
struct StatChip: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
                .foregroundColor(MZColor.textMuted)
            Text(value)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(white: 0.12))
                .overlay(
                    Capsule()
                        .stroke(MZColor.glassBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    let message: String?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if let message = message, isPresented {
                        VStack {
                            Spacer()
                            Text(message)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.8))
                                        .overlay(
                                            Capsule()
                                                .stroke(MZColor.accentPurple, lineWidth: 1)
                                        )
                                )
                                .padding(.bottom, 40)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                }
                        }
                    }
                }
            )
    }
}

extension View {
    func toast(message: String?, isPresented: Binding<Bool>) -> some View {
        modifier(ToastModifier(message: message, isPresented: isPresented))
    }
}