import SwiftUI

struct TypeGameView: View {
    @Bindable var gameState: GameState

    private let cards: [(prey: PreyType, x: CGFloat, spriteW: CGFloat, spriteH: CGFloat)] = [
        (.bird,   272,  175, 169),
        (.mouse,  545,  154, 159),
        (.thread, 822,  181, 135),
        (.mix,    1095, 134, 141)
    ]

    var body: some View {
        ZStack {
            // 1. Title "SELECT TOYS"
            OutlinedText(
                text: "SELECT TOYS",
                fontSize: 64,
                fillColor: Color(red: 0.90, green: 0.74, blue: 0.64),
                strokeColor: Color(red: 0.52, green: 0.34, blue: 0.22),
                lineWidth: 3.5
            )
            .position(x: 683, y: 153)

            // 2. 4 Real Liquid Glass Toy Squircle Buttons
            ForEach(cards, id: \.prey) { item in
                let isSelected = gameState.selectedPrey == item.prey
                ToyGlassButton(
                    prey: item.prey,
                    isSelected: isSelected,
                    spriteWidth: item.spriteW,
                    spriteHeight: item.spriteH
                ) {
                    SoundManager.shared.playSound(named: item.prey.soundName)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                        gameState.selectedPrey = item.prey
                    }
                }
                .position(x: item.x, y: 495)
            }
        }
    }
}

/// Real Native Liquid Glass Squircle Toy Button
struct ToyGlassButton: View {
    let prey: PreyType
    let isSelected: Bool
    let spriteWidth: CGFloat
    let spriteHeight: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 18) {
                AssetImageView(name: prey.spriteImageName)
                    .frame(width: spriteWidth, height: spriteHeight)
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .frame(width: 246.5, height: 240)
                    .contentShape(RoundedRectangle(cornerRadius: 68, style: .continuous))
                    .glassEffect(
                        (isSelected
                            ? Glass.regular.tint(Color(red: 0.30, green: 0.72, blue: 0.96).opacity(0.40))
                            : Glass.regular
                        ).interactive(),
                        in: .rect(cornerRadius: 68)
                    )

                OutlinedText(
                    text: prey.rawValue.uppercased(),
                    fontSize: 38,
                    fillColor: isSelected
                        ? Color(red: 0.96, green: 0.92, blue: 0.88)
                        : Color(red: 0.85, green: 0.80, blue: 0.77),
                    strokeColor: Color(white: 0.22),
                    lineWidth: 2.2
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.04 : 1.0)
    }
}

/// Crisp outlined rounded text matching Sketch typography
struct OutlinedText: View {
    let text: String
    let fontSize: CGFloat
    let fillColor: Color
    let strokeColor: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            ForEach([-1.0, 0.0, 1.0], id: \.self) { dx in
                ForEach([-1.0, 0.0, 1.0], id: \.self) { dy in
                    if dx != 0 || dy != 0 {
                        Text(text)
                            .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                            .foregroundStyle(strokeColor)
                            .offset(x: dx * lineWidth, y: dy * lineWidth)
                    }
                }
            }
            Text(text)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(fillColor)
        }
    }
}
