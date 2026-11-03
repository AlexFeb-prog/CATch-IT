// Haptics.swift
import Foundation
#if os(iOS)
import UIKit
import AudioToolbox
#elseif os(macOS)
import AppKit
#endif
import AVFoundation

/// Gestore haptic / vibrazione cross-platform (iOS, iPadOS e macOS)
/// Offre vibrazione fisica su iPhone/iPad e feedback tattile su Mac (Trackpad Taptic Engine + sub-bass motor).
@MainActor
enum Haptics {
    #if os(iOS)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let soft = UIImpactFeedbackGenerator(style: .soft)
    #endif

    // Generatore di impulso fisico a bassissima frequenza (45Hz - rumble aptico percepibile dai felini e su casse/iPad)
    private static let rumble = SubBassRumble()

    /// Feedback zampata: vibrazione fisica reale su qualsiasi dispositivo
    static func catchPaw() {
        #if os(iOS)
        // 1. Taptic Engine UIKit: sequenza dinamica heavy + soft
        heavy.prepare()
        soft.prepare()
        heavy.impactOccurred(intensity: 1.0)

        // 2. Vibrazione di sistema reale dell'hardware (CoreAudio / Motor)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(90))
            soft.impactOccurred(intensity: 0.7)
        }
        #elseif os(macOS)
        // 1. Force Touch Trackpad haptic feedback su Mac (Taptic Engine hardware)
        let performer = NSHapticFeedbackManager.defaultPerformer
        performer.perform(.levelChange, performanceTime: .now)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            performer.perform(.generic, performanceTime: .now)
        }
        #endif

        // 3. Sub-bass physical vibration burst (rumble a 45Hz di 120ms):
        // crea vibrazione meccanica fisica attraverso il trasduttore audio del tablet/Mac
        rumble.playRumble()
    }
}

/// Emettitore di micro-impulso a bassa frequenza (45Hz) per far vibrare fisicamente la scocca
private final class SubBassRumble: @unchecked Sendable {
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var rumbleBuffer: AVAudioPCMBuffer?

    init() {
        setupBuffer()
    }

    private func setupBuffer() {
        let sampleRate: Double = 44100.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
        let duration: Double = 0.12 // 120 ms burst
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let channels = buffer.floatChannelData
        guard let channelData = channels?[0] else { return }

        let frequency: Double = 48.0 // 48 Hz pura vibrazione fisica
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = sin(Double.pi * (t / duration)) // Hann envelope per evitare click
            let sample = Float(sin(2.0 * Double.pi * frequency * t) * envelope)
            channelData[i] = sample * 0.95
        }
        self.rumbleBuffer = buffer

        let eng = AVAudioEngine()
        let player = AVAudioPlayerNode()
        eng.attach(player)
        eng.connect(player, to: eng.mainMixerNode, format: format)
        try? eng.start()
        self.engine = eng
        self.playerNode = player
    }

    func playRumble() {
        guard let engine = engine, let player = playerNode, let buffer = rumbleBuffer else { return }
        if !engine.isRunning {
            try? engine.start()
        }
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        player.play()
    }
}
