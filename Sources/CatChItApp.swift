import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct CatChItApp: App {
    init() {
        #if os(macOS)
        // Imposta l'icona dell'applicazione nel Dock a runtime da codice
        if let iconUrl = Bundle.main.url(forResource: "app_icon", withExtension: "png") ??
                         Bundle.main.url(forResource: "game_logo", withExtension: "png"),
           let image = NSImage(contentsOf: iconUrl) {
            NSApplication.shared.applicationIconImage = image
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 825)
        #endif
    }
}
