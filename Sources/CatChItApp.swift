import SwiftUI
#if os(macOS)
import AppKit

final class FullSizeWindowAccessor: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window = self.window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
    }
}

struct WindowAccessorView: NSViewRepresentable {
    func makeNSView(context: Context) -> FullSizeWindowAccessor {
        FullSizeWindowAccessor()
    }
    func updateNSView(_ nsView: FullSizeWindowAccessor, context: Context) {}
}
#endif

@main
struct CatChItApp: App {
    init() {
        #if os(macOS)
        // Imposta dinamicamente l'icona dell'applicazione nel Dock da codice
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
                .ignoresSafeArea()
                #if os(macOS)
                .background(WindowAccessorView().allowsHitTesting(false))
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 825)
        #endif
    }
}
