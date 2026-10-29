import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()

    var body: some View {
        ZStack {
            if gameState.isPlaying {
                GamePlayView(gameState: gameState)
                    .transition(.opacity)
            } else {
                // Persistent background for real Liquid Glass optical refraction
                GeometryReader { geo in
                    AssetImageView(name: "clean_bg", contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()

                // Unified DesignCanvas: scales to fit the window while keeping exact Sketch layout
                DesignCanvas {
                    ZStack {
                        // Current active page view
                        Group {
                            switch gameState.currentTab {
                            case .typeGame:
                                TypeGameView(gameState: gameState)
                            case .home:
                                HomeView(gameState: gameState)
                            case .settings:
                                SettingsView(gameState: gameState)
                            }
                        }
                        .transition(.opacity)

                        // Persistent Bottom Liquid Glass Dock: always visible and interactive across tabs
                        GlassDock(gameState: gameState)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
        .animation(.smooth(duration: 0.28), value: gameState.currentTab)
        .animation(.smooth(duration: 0.32), value: gameState.isPlaying)
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}

/// Bottom navigation: three circular native Liquid Glass buttons
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
                    AssetImageView(name: item.icon)
                        .frame(width: 86, height: 86)
                        .frame(width: 127, height: 126)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(
                    (selected
                        ? Glass.regular.tint(Color(red: 0.35, green: 0.75, blue: 0.98).opacity(0.38))
                        : Glass.regular
                    ).interactive(),
                    in: .circle
                )
                .position(x: item.x, y: selected ? 836 : 862)
            }
        }
    }
}
