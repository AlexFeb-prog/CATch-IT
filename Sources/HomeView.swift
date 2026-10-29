import SwiftUI

struct HomeView: View {
    @Bindable var gameState: GameState
    @State private var catBounce: CGFloat = 0
    @State private var playPulse: CGFloat = 1.0

    var body: some View {
        DesignCanvas {
            ZStack {
                // 1. Play Button with real Apple Liquid Glass (placed below cat paws in Z-order)
                Button {
                    SoundManager.shared.playSound(named: "catch_pop")
                    gameState.startSession()
                } label: {
                    HStack(spacing: 22) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 80, weight: .bold))
                        Text("Play")
                            .font(.system(size: 98, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 662, height: 231)
                    .background(
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.70, green: 0.90, blue: 0.99).opacity(0.78),
                                        Color(red: 0.56, green: 0.84, blue: 0.98).opacity(0.68)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .glassEffect(.regular, in: Capsule(style: .continuous))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.95), Color.white.opacity(0.35)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2.5
                                    )
                            )
                            .shadow(color: Color(red: 0.15, green: 0.35, blue: 0.55).opacity(0.22), radius: 16, y: 8)
                    )
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .scaleEffect(playPulse)
                .position(x: 683, y: 368)

                // 2. Cat on top (paws resting naturally over the top edge of the Play button)
                AssetImageView(name: "cat_peeking")
                    .frame(width: 534, height: 337)
                    .position(x: 683, y: 168 + catBounce)
                    .allowsHitTesting(false)

                // 3. Logo CATch It!
                AssetImageView(name: "logo_catchit")
                    .frame(width: 861, height: 214)
                    .position(x: 683, y: 617)
                    .allowsHitTesting(false)

                // 4. Bottom Liquid Glass Dock
                GlassDock(gameState: gameState)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                catBounce = -6
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                playPulse = 1.02
            }
        }
    }
}

/// Bottom navigation: three circular Liquid Glass buttons matching main-3.sketch & Immagini 2
struct GlassDock: View {
    @Bindable var gameState: GameState

    private let items: [(tab: AppTab, icon: String, x: CGFloat)] = [
        (.typeGame, "icon_yarn", 264),
        (.home,     "icon_paw",  697),
        (.settings, "icon_gear", 1135)
    ]

    var body: some View {
        ZStack {
            ForEach(items, id: \.tab) { item in
                let selected = gameState.currentTab == item.tab
                Button {
                    SoundManager.shared.playSound(named: "ui_tap")
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
                        gameState.currentTab = item.tab
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.93, blue: 1.0).opacity(selected ? 0.82 : 0.65),
                                        Color(red: 0.74, green: 0.86, blue: 0.98).opacity(selected ? 0.75 : 0.55)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .glassEffect(.regular, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        selected ?
                                            Color(red: 0.38, green: 0.56, blue: 0.82) :
                                            Color.white.opacity(0.65),
                                        lineWidth: selected ? 3.5 : 1.5
                                    )
                            )
                            .shadow(
                                color: Color.black.opacity(selected ? 0.22 : 0.14),
                                radius: selected ? 10 : 6,
                                y: 4
                            )
                            .frame(width: 127, height: 126)

                        AssetImageView(name: item.icon)
                            .frame(width: 86, height: 86)
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .position(x: item.x, y: selected ? 836 : 862)
            }
        }
    }
}
