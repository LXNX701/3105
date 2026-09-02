//
//  MoonzazaPatchManager.swift
//  ThreeOneOSFive
//
//  Módulo para gestionar la aplicación de parches de Free Fire
//  usando el sandbox escape (MobileHouseArrest)
//

import Foundation
import SwiftUI

enum PatchLevel: String, CaseIterable {
    case off = "OFF"
    case normal = "NORMAL"
    case max = "MAX"
}

struct FreefirePatch: Identifiable {
    let id: String
    var displayName: String
    var level: PatchLevel
    var targetApp: TargetApp
    
    enum TargetApp {
        case normal   // com.dts.freefire
        case max      // com.dts.freefiremax
    }
}

@MainActor
class MoonzazaPatchManager: ObservableObject {
    
    @Published var patches: [FreefirePatch] = [
        FreefirePatch(id: "AIM_DRAG", displayName: "AIM DRAG", level: .off, targetApp: .max),
        FreefirePatch(id: "AIM_CUELLO", displayName: "AIM CUELLO", level: .off, targetApp: .max),
        FreefirePatch(id: "AIM_BALA_MAGICA", displayName: "AIM BALA MAGICA", level: .off, targetApp: .max),
        FreefirePatch(id: "AIM_PECHO", displayName: "AIM PECHO", level: .off, targetApp: .max)
    ]
    
    @Published var targetApp: FreefirePatch.TargetApp = .max
    @Published var isApplying = false
    @Published var isRestoring = false
    @Published var lastResultMessage: String?
    
    private let fileManager = FileManager.default
    
    // MARK: - Aplicar parches activos
    
    func applyPatches() async throws {
        isApplying = true
        defer { isApplying = false }
        
        let activePatches = patches.filter { $0.level != .off }
        guard !activePatches.isEmpty else {
            throw NSError(domain: "PatchError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "No patches selected."])
        }
        
        guard let firstPatch = activePatches.first else {
            throw NSError(domain: "PatchError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "No active patches found."])
        }
        
        let bundleID = firstPatch.targetApp == .normal ? "com.dts.freefire" : "com.dts.freefiremax"
        let containerPath = try await getContainerPath(for: bundleID)
        
        // Mapeo: cada patch ID → nombre de su carpeta en Resources/Patches/MOONZAZA/
        let patchFolderMap: [String: String] = [
            "AIM_DRAG": "AIM_DRAG",
            "AIM_CUELLO": "AIM_CUELLO",
            "AIM_BALA_MAGICA": "AIM_BALA MAGICA",
            "AIM_PECHO": "AIM_PECHO"
        ]
        
        // Nombre del archivo fuente (el mismo en todas las carpetas)
        let sourceFileName = "assetindexer.PENojQAQf9a1l6Dzjs0n1Z3rtVU~3D"
        
        // Ruta de destino DENTRO del contenedor (donde espera Free Fire el archivo)
        // NOTA: No hay subcarpeta adicional, va directamente en avatar/
        let destinationPath = "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/\(sourceFileName)"
        
        // Obtener el archivo ORIGINAL (backup) desde la raíz de Patches/MOONZAZA/
        let originalFileName = "assetindexer.PENojQAQf9a1l6Dzjs0n1Z3rtVU~3D"
        let originalPath = "Patches/MOONZAZA/\(originalFileName)"
        let originalBundlePath = Bundle.main.path(forResource: originalFileName,
                                                   ofType: nil,
                                                   inDirectory: "Patches/MOONZAZA")
        
        // Verificar que existe el archivo original (backup)
        if let originalPath = originalBundlePath {
            print("[MOONZAZA] 📁 Original file found at: \(originalPath)")
        } else {
            print("[MOONZAZA] ⚠️ Original file not found in bundle")
        }
        
        for patch in activePatches {
            guard let folder = patchFolderMap[patch.id] else {
                print("[MOONZAZA] ⚠️ No folder mapping for patch: \(patch.id)")
                continue
            }
            
            // Buscar el archivo fuente en la subcarpeta correspondiente
            guard let bundlePath = Bundle.main.path(forResource: sourceFileName,
                                                    ofType: nil,
                                                    inDirectory: "Patches/MOONZAZA/\(folder)") ??
                                    Bundle.main.path(forResource: "Patches/MOONZAZA/\(folder)/\(sourceFileName)",
                                                    ofType: nil) else {
                throw NSError(domain: "PatchError", code: 2,
                             userInfo: [NSLocalizedDescriptionKey: "Missing patch file for '\(patch.displayName)': \(sourceFileName) in folder \(folder)"])
            }
            
            let sourceURL = URL(fileURLWithPath: bundlePath)
            let destURL = containerPath.appendingPathComponent(destinationPath)
            
            // Crear la carpeta de destino si no existe
            let destDir = destURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: destDir.path) {
                try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true, attributes: nil)
                print("[MOONZAZA] 📁 Created directory: \(destDir.path)")
            }
            
            // Sobrescribir si ya existe
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destURL)
            
            print("[MOONZAZA] ✅ Applied \(patch.displayName) from '\(folder)' -> \(destURL.path)")
        }
        
        lastResultMessage = "✅ Patches applied successfully! (\(activePatches.count) applied)"
    }
    
    // MARK: - Restaurar archivo original (usando el backup del bundle)
    
    func restoreOriginals() async throws {
        isRestoring = true
        defer { isRestoring = false }
        
        guard let firstPatch = patches.first else {
            throw NSError(domain: "PatchError", code: 3,
                         userInfo: [NSLocalizedDescriptionKey: "No patches defined."])
        }
        
        let bundleID = firstPatch.targetApp == .normal ? "com.dts.freefire" : "com.dts.freefiremax"
        let containerPath = try await getContainerPath(for: bundleID)
        
        let sourceFileName = "assetindexer.PENojQAQf9a1l6Dzjs0n1Z3rtVU~3D"
        let destinationPath = "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/\(sourceFileName)"
        let destURL = containerPath.appendingPathComponent(destinationPath)
        
        // Buscar el archivo ORIGINAL (backup) en la raíz de Patches/MOONZAZA/
        guard let originalBundlePath = Bundle.main.path(forResource: sourceFileName,
                                                        ofType: nil,
                                                        inDirectory: "Patches/MOONZAZA") ??
                                        Bundle.main.path(forResource: "Patches/MOONZAZA/\(sourceFileName)",
                                                        ofType: nil) else {
            throw NSError(domain: "PatchError", code: 4,
                         userInfo: [NSLocalizedDescriptionKey: "Original file not found in bundle."])
        }
        
        let originalURL = URL(fileURLWithPath: originalBundlePath)
        
        // Sobrescribir con el original
        if fileManager.fileExists(atPath: destURL.path) {
            try fileManager.removeItem(at: destURL)
        }
        try fileManager.copyItem(at: originalURL, to: destURL)
        
        print("[MOONZAZA] 🗑️ Restored original file: \(destURL.path)")
        lastResultMessage = "✅ Original file restored!"
    }
    
    // MARK: - Lanzar Free Fire
    
    func launchApp(_ bundleID: String) {
        guard let url = URL(string: "\(bundleID)://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("[MOONZAZA] 🚀 Launched \(bundleID)")
        } else {
            print("[MOONZAZA] ❌ Cannot open \(bundleID)")
        }
    }
    
    // MARK: - Obtener ruta del contenedor usando el sandbox escape
    
    private func getContainerPath(for bundleID: String) async throws -> URL {
        // ⚠️ AQUÍ DEBES USAR LA IMPLEMENTACIÓN REAL DE 3105
        // Ejemplo: guard let path = SBX.getContainerPath(bundleID) else { ... }
        // Por ahora, simulamos (esto fallará en dispositivo real)
        let simulatedPath = "/var/mobile/Containers/Data/Application/\(UUID().uuidString)"
        print("[MOONZAZA] ⚠️ Using simulated container path: \(simulatedPath)")
        return URL(fileURLWithPath: simulatedPath)
    }
}