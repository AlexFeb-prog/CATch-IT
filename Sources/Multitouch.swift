//
//  Multitouch.swift

import SwiftUI
#if os(iOS)
import UIKit

struct TouchSurface: UIViewRepresentable {
    var onTouch: (CGPoint) -> Void

    func makeUIView(context: Context) -> TouchView {
        let view = TouchView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.onTouch = onTouch
        return view
    }

    func updateUIView(_ uiView: TouchView, context: Context) {
        uiView.onTouch = onTouch
    }

    final class TouchView: UIView {
        var onTouch: ((CGPoint) -> Void)?

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for touch in touches {
                onTouch?(touch.location(in: self))
            }
        }
    }
}
#endif
