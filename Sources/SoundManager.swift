import Foundation
import AVFoundation

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]
    var volume: Float = 1.0 {
        didSet { players.values.forEach { $0.volume = volume } }
    }

    private init() {
        ["mouse_squeak", "bird_chirp", "thread_friction",
         "catch_pop", "ambient_rustle", "ui_tap"].forEach(preload)
    }

    private func preload(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = volume
            players[name] = player
        } catch {
            print("Failed to load sound \(name): \(error)")
        }
    }

    func playSound(named name: String) {
        guard volume > 0.01, let player = players[name] else { return }
        player.currentTime = 0
        player.volume = volume
        player.play()
    }
}
