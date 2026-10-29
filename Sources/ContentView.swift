import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()

    var body: some View {
        ZStack {
            if gameState.isPlaying {
                GamePlayView(gameState: gameState)
            } else {
                // The backdrop sits behind everything so the real Liquid Glass has something to refract.
                GeometryReader { geo in
                    AssetImageView(name: "clean_bg", contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()

                Group {
                    switch gameState.currentTab {
                    case .typeGame: TypeGameView(gameState: gameState)
                    case .home:     HomeView(gameState: gameState)
                    case .settings: SettingsView(gameState: gameState)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.25), value: gameState.currentTab)
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}
