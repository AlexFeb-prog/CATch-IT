import SwiftUI

struct PreySpriteView: View {
    let prey: PreyEntity

    /// Facing direction: mirror when heading left
    private var facingLeft: Bool { cos(prey.angle) < 0 }
    private var tilt: Double {
        let t = atan2(sin(prey.angle), abs(cos(prey.angle)))
        let c = max(-0.4, min(0.4, t))
        return facingLeft ? -c : c
    }

    /// Selects animated frame sequence from cat_sprites_frames
    private var currentFrameName: String {
        switch prey.type {
        case .bird:
            if prey.pauseTimer > 0 {
                return "bird_02"
            }
            let idx = Int(prey.flutterTimer * 12) % 6
            return String(format: "bird_%02d", idx)
        case .mouse:
            if prey.pauseTimer > 0 {
                return "mouse_00"
            }
            let idx = Int(prey.flutterTimer * 14) % 6
            return String(format: "mouse_%02d", idx)
        case .thread:
            let idx = Int(prey.flutterTimer * 10) % 8
            return String(format: "yarn_%02d", idx)
        case .mix:
            return "sprite_dice"
        }
    }

    var body: some View {
        ZStack {
            // Drop shadow
            Ellipse()
                .fill(Color.black.opacity(prey.type == .bird ? 0.16 : 0.22))
                .frame(width: (prey.type == .bird ? 95 : 80) * prey.scale,
                       height: (prey.type == .bird ? 42 : 30) * prey.scale)
                .offset(y: prey.type == .bird ? 64 : 48)
                .blur(radius: prey.type == .bird ? 8 : 4)

            // Animated Prey Sprite
            AssetImageView(name: currentFrameName)
                .frame(width: 135 * prey.scale, height: 135 * prey.scale)
                .scaleEffect(x: facingLeft ? -1 : 1, y: 1)
                .rotationEffect(.radians(tilt))
        }
    }
}
