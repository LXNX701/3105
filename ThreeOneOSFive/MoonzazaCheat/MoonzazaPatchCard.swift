import SwiftUI

struct MoonzazaPatchCard: View {
    @Binding var patch: FreefirePatch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(patch.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            
            Picker("Level", selection: $patch.level) {
                Text("OFF").tag(PatchLevel.off)
                Text("NORMAL").tag(PatchLevel.normal)
                Text("MAX").tag(PatchLevel.max)
            }
            .pickerStyle(.segmented)
            .tint(statusColor)
            .labelsHidden()
            .frame(height: 30)
            .colorMultiply(statusColor)
        }
        .padding()
        .glassmorphism()
        .neonBorder()
    }
    
    private var statusColor: Color {
        switch patch.level {
        case .off: return Color.gray
        case .normal: return MZColor.accentGold
        case .max: return MZColor.accentRed
        }
    }
}