import Foundation
import SwiftUI

// MARK: - Patch Level
enum PatchLevel: String, CaseIterable {
    case off = "OFF"
    case normal = "NORMAL"
    case max = "MAX"
}

// MARK: - Patch Model
struct FreefirePatch: Identifiable {
    let id: String // e.g. "AIM_DRAG"
    var displayName: String
    var level: PatchLevel
    var targetApp: TargetApp = .normal
    
    enum TargetApp {
        case normal   // com.dts.freefire
        case max      // com.dts.freefiremax
    }
}

// MARK: - Patch Manager
@MainActor
class MoonzazaPatchManager: ObservableObject {
    @Published var patches: [FreefirePatch] = [
        FreefirePatch(id: "AIM_DRAG", displayName: "AIM DRAG", level: .off, targetApp: .normal),
        FreefirePatch(id: "AIM_CHEST", displayName: "AIM CHEST", level: .off, targetApp: .normal),
        FreefirePatch(id: "PECHO", displayName: "PECHO", level: .off, targetApp: .max),
        FreefirePatch(id: "AIM_PECHO", displayName: "AIM PECHO", level: .off, targetApp: .max)
    ]
    
    @Published var targetApp: FreefirePatch.TargetApp = .normal
    @Published var isApplying = false
    @Published var isRestoring = false
    @Published var lastResultMessage: String?
    
    private let fileManager = FileManager.default
    
    // MARK: - Apply Patches
    func applyPatches() async throws {
        isApplying = true
        defer { isApplying = false }
        
        let activePatches = patches.filter { $0.level != .off }
        guard !activePatches.isEmpty else {
            throw NSError(domain: "PatchError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No patches selected."])
        }
        
        // Determine target bundle ID based on first active patch
        guard let first = activePatches.first else { return }
        let bundleID = first.targetApp == .normal ? "com.dts.freefire" : "com.dts.freefiremax"
        
        // Use SBX (sandbox escape) to get container path
        let containerPath = try await getContainerPath(for: bundleID)
        let documentsPath = try getDocumentsPath()
        let patchFolder = documentsPath.appendingPathComponent("Patches/MOONZAZA")
        
        for patch in activePatches {
            let levelStr = patch.level == .normal ? "NORMAL" : "MAX"
            let fileName = "\(patch.id)_\(levelStr).bin"
            let sourceFile = patchFolder.appendingPathComponent(fileName)
            let destFile = containerPath.appendingPathComponent("Documents/\(patch.id.lowercased()).bin") // example
            // Aquí debes ajustar la ruta de destino según el archivo real que reemplaza el parche.
            // Por ahora, usamos un destino genérico.
            
            // Check source exists
            guard fileManager.fileExists(atPath: sourceFile.path) else {
                throw NSError(domain: "PatchError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing patch file: \(fileName)"])
            }
            
            // Use FileReplacementService (existente en 3105) para copiar con backup
            // Simulamos: simplemente copiamos con FileManager (en la práctica, usa la función de reemplazo)
            try fileManager.copyItem(at: sourceFile, to: destFile)
        }
        
        lastResultMessage = "Patches applied successfully!"
    }
    
    // MARK: - Restore Originals
    func restoreOriginals() async throws {
        isRestoring = true
        defer { isRestoring = false }
        
        // Llama al servicio de restauración existente en 3105 (DevicePatchService)
        // Por simplicidad, aquí simulamos:
        lastResultMessage = "Originals restored!"
    }
    
    // MARK: - Launch App
    func launchApp(_ bundleID: String) {
        guard let url = URL(string: "\(bundleID)://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback: intentar abrir con LSApplicationWorkspace
            // (se puede implementar si es necesario)
            print("[MOONZAZA] Cannot open \(bundleID)")
        }
    }
    
    // MARK: - Helpers
    private func getContainerPath(for bundleID: String) async throws -> URL {
        // Usa el SBX (sandbox escape) existente en 3105
        // Esto debería llamar a SBX.getContainerPath(bundleID)
        // Por ahora, devolvemos una ruta simulada.
        // En la práctica, debes usar la implementación de 3105.
        let path = "/private/var/mobile/Containers/Data/Application/\(UUID().uuidString)" // placeholder
        return URL(fileURLWithPath: path)
    }
    
    private func getDocumentsPath() throws -> URL {
        try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}