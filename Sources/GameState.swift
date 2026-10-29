import SwiftUI

enum PreyType: String, CaseIterable, Identifiable {
    case bird = "Bird"
    case mouse = "Mouse"
    case thread = "Thread"
    case mix = "Mix"
    
    var id: String { rawValue }
    
    var cardImageName: String {
        switch self {
        case .bird: return "card_bird"
        case .mouse: return "card_mouse"
        case .thread: return "card_thread"
        case .mix: return "card_mix"
        }
    }
    
    var spriteImageName: String {
        switch self {
        case .bird: return "sprite_bird"
        case .mouse: return "sprite_mouse"
        case .thread: return "sprite_thread"
        case .mix: return "sprite_dice"
        }
    }
    
    var soundName: String {
        switch self {
        case .bird: return "bird_chirp"
        case .mouse: return "mouse_squeak"
        case .thread: return "thread_friction"
        case .mix: return "catch_pop"
        }
    }
}

enum AppTab: Int {
    case typeGame = 0
    case home = 1
    case settings = 2
}

enum SettingsSection: String, CaseIterable {
    case audio = "Audio"
    case gioco = "Gioco"
}

@Observable
final class GameState {
    var currentTab: AppTab = .home
    var selectedPrey: PreyType = .mouse
    var isPlaying: Bool = false
    
    // Audio options
    var volume: Double = 1.0 {
        didSet {
            SoundManager.shared.volume = Float(volume)
        }
    }
    
    // Gioco options
    var speedMultiplier: Double = 1.0 // 0.5x to 2.0x
    var durationMinutes: Int = 3       // 1, 3, 5, 10 minutes (or 0 for infinite)
    var preyCount: Int = 2            // 1, 2, 3, 4, 5
    
    // Score & stats
    var catCatches: Int = 0
    var sessionTimeRemaining: TimeInterval = 180
    
    func startSession() {
        catCatches = 0
        sessionTimeRemaining = Double(durationMinutes * 60)
        isPlaying = true
    }
    
    func stopSession() {
        isPlaying = false
    }
}
