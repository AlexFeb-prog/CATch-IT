import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()

    var body: some View {
        ZStack {
            if gameState.isPlaying {
                GamePlayView(gameState: gameState)
                    .transition(.opacity)
            } else {
                // Persistent background
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
