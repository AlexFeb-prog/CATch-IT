import Foundation
import AVFoundation

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()

    /// Nome usato nel gioco → file nel bundle (con estensione)
    private let files: [String: String] = [
        // Verso delle prede
        "bird_chirp": "bird2.mp3.mpeg",
        "mouse_squeak": "Mouse.mp3.mpeg",
        "thread_friction": "theread.mp3.mpeg",
        // Inizio partita
        "game_start": "Cat.mp3.mpeg",
        // Cattura: un pop per tipo
        "pop_bird": "pop_bird.wav",
        "pop_mouse": "pop_mouse.wav",
        "pop_thread": "pop_thread.wav",
        "catch_pop": "catch_pop.wav",
        // Interfaccia e ambiente
        "ambient_rustle": "ambient_rustle.wav",
        "ui_tap": "ui_tap.wav",
    ]

    private var urls: [String: URL] = [:]
    private var players: [String: AVAudioPlayer] = [:]      // suoni brevi: pop, tap, avvio
    private var preyPlayers: [UUID: AVAudioPlayer] = [:]    // un verso per ogni preda

    var volume: Float = 1.0 {
        didSet {
            players.values.forEach { $0.volume = volume }
            preyPlayers.values.forEach { $0.volume = volume }
        }
    }

    private init() {
        files.keys.forEach(preload)
    }

    private func preload(_ name: String) {
        guard let file = files[name] else { return }
        let base = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: base, withExtension: ext) else {
            print("⚠️ File audio mancante: \(file)")
            return
        }
        urls[name] = url
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = volume
            players[name] = player
        } catch {
            print("Failed to load sound \(name): \(error)")
        }
    }

    /// Suoni brevi di interfaccia e cattura
    func playSound(named name: String) {
        let soundKey = (players[name] != nil) ? name : "catch_pop"
        guard volume > 0.01, let player = players[soundKey] else { return }
        player.currentTime = 0
        player.volume = volume
        player.play()
    }

    /// Verso di una singola preda: se ne parte un altro per la stessa preda, sostituisce il precedente
    func playPreySound(named name: String, for id: UUID) {
        guard volume > 0.01, let url = urls[name] else { return }
        preyPlayers[id]?.stop()
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.prepareToPlay()
        player.play()
        preyPlayers[id] = player
    }

    /// Ferma il verso di una preda, da chiamare quando viene catturata
    func stopPreySound(for id: UUID) {
        preyPlayers[id]?.stop()
        preyPlayers[id] = nil
    }

    /// Ferma tutti i versi delle prede
    func stopPreySounds() {
        preyPlayers.values.forEach { $0.stop() }
        preyPlayers.removeAll()
    }

    /// Ferma tutto, da chiamare quando si esce dalla partita
    func stopAll() {
        players.values.forEach { $0.stop() }
        stopPreySounds()
    }
}
