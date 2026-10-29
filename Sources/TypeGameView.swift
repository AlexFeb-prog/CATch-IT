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
            // 1. Title "SELECT TOYS" matching main-3.sketch & Immagini 2
            OutlinedText(
                text: "SELECT TOYS",
                fontSize: 64,
                fillColor: Color(red: 0.90, green: 0.74, blue: 0.64),
                strokeColor: Color(red: 0.52, green: 0.34, blue: 0.22),
                lineWidth: 3.5
            )
            .position(x: 683, y: 153)

            // 2. 4 Liquid Glass Toy Squircle Buttons
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

/// Real Liquid Glass Squircle Toy Button matching main-3.sketch & Immagini 2
struct ToyGlassButton: View {
    let prey: PreyType
    let isSelected: Bool
    let spriteWidth: CGFloat
    let spriteHeight: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.71, green: 0.83, blue: 0.88).opacity(0.68),
                                    Color(red: 0.35, green: 0.56, blue: 0.67).opacity(0.76)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 100, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                .stroke(
                                    isSelected ? Color.black : Color(white: 0.68),
                                    lineWidth: isSelected ? 4.0 : 1.5
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(isSelected ? 0.34 : 0.22),
                            radius: isSelected ? 10 : 6,
                            y: 5
                        )
                        .frame(width: 246.5, height: 240)

                    AssetImageView(name: prey.spriteImageName)
                        .frame(width: spriteWidth, height: spriteHeight)
                        .scaleEffect(isSelected ? 1.06 : 1.0)
                }

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
        .scaleEffect(isSelected ? 1.03 : 1.0)
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
