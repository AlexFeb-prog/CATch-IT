// ScreenAwake.swift
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
enum ScreenAwake {
    #if os(macOS)
    private static var activity: NSObjectProtocol?
    #endif

    static func set(_ on: Bool) {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = on
        #elseif os(macOS)
        if on {
            activity = ProcessInfo.processInfo.beginActivity(
                options: .idleDisplaySleepDisabled,
                reason: "Partita in corso"
            )
        } else if let token = activity {
            ProcessInfo.processInfo.endActivity(token)
            activity = nil
        }
        #endif
    }
}
