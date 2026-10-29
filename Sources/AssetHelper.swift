import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformImage = NSImage
#endif

/// Loads each bundled PNG once (no disk I/O at 60 fps).
enum ImageCache {
    private static let cache = NSCache<NSString, PlatformImage>()

    static func image(named name: String) -> PlatformImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let img = PlatformImage(contentsOfFile: path) else { return nil }
        cache.setObject(img, forKey: name as NSString)
        return img
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #else
        self.init(nsImage: platformImage)
        #endif
    }
}

struct AssetImageView: View {
    let name: String
    var contentMode: ContentMode = .fit

    var body: some View {
        if let img = ImageCache.image(named: name) {
            Image(platformImage: img)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Color.clear
        }
    }
}

/// Lays content out on the 1366x1024 Sketch artboard and scales it to fit any screen, anchored flush to the top edge.
struct DesignCanvas<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / 1366, geo.size.height / 1024)
            content()
                .frame(width: 1366, height: 1024)
                .scaleEffect(s, anchor: .top)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
    }
}
