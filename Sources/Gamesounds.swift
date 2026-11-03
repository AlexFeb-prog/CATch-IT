//// GameSounds.swift
// I nomi devono corrispondere ai file audio nel progetto, con il target spuntato
enum GameSounds {
    static let uiTap = "ui_tap"
    static let rustle = "ambient_rustle"
}

extension PreyType {
    /// Pop alla cattura: uno per tipo di preda
    var popSound: String {
        switch self {
        case .bird: return "pop_bird"
        case .mouse: return "pop_mouse"
        case .thread: return "pop_thread"
        case .mix: return "pop_mix"
        }
    }
}
