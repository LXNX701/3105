import SwiftUI
import UIKit

struct MoonzazaParticleView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        emitterLayer.renderMode = .additive
        
        // Configurar celdas
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "sparkle")?.cgImage
        cell.birthRate = 5
        cell.lifetime = 6.0
        cell.velocity = 80
        cell.velocityRange = 40
        cell.emissionRange = .pi / 4
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.color = UIColor(red: 0.6, green: 0.0, blue: 0.8, alpha: 0.6).cgColor
        cell.alphaSpeed = -0.05
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}