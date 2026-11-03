// PreyLocomotion.swift
import SwiftUI

extension PreyType {
    /// Distanza dai bordi oltre la quale la preda torna verso il centro
    var margin: CGFloat {
        switch self {
        case .bird: return 90
        case .mouse: return 70
        case .thread: return 100
        case .mix: return 80
        }
    }

    /// Velocità massima di rotazione (rad/s)
    var maxTurnRate: Double {
        switch self {
        case .bird: return 1.4
        case .mouse: return 3.5
        case .thread: return 0.7
        case .mix: return 2.0
        }
    }

    /// Quanto la direzione cambia a caso: più alto = traiettorie più irregolari
    var turnJitter: Double {
        switch self {
        case .bird: return 1.2
        case .mouse: return 5.0
        case .thread: return 0.6
        case .mix: return 2.0
        }
    }

    /// Ritmo di crociera, moltiplicatore della velocità base
    var cruiseRange: ClosedRange<Double> {
        switch self {
        case .bird: return 0.8...1.2
        case .mouse: return 0.7...1.2
        case .thread: return 0.6...0.9
        case .mix: return 0.8...1.2
        }
    }

    /// Probabilità di uno scatto (o decollo) al secondo
    var dashChance: Double {
        switch self {
        case .bird: return 0.25
        case .mouse: return 0.35
        case .thread: return 0.06
        case .mix: return 0.2
        }
    }

    /// Moltiplicatore di velocità durante lo scatto
    var dashFactorRange: ClosedRange<Double> {
        switch self {
        case .bird: return 1.6...2.2
        case .mouse: return 1.8...2.4
        case .thread: return 1.3...1.6
        case .mix: return 1.6...2.2
        }
    }

    /// Probabilità di uno stop improvviso al secondo
    var pauseChance: Double {
        switch self {
        case .bird: return 0.12
        case .mouse: return 0.3
        case .thread: return 0.2
        case .mix: return 0.2
        }
    }

    /// Durata dello stop, in secondi
    var pauseRange: ClosedRange<Double> {
        switch self {
        case .bird: return 0.15...0.5
        case .mouse: return 0.1...0.4
        case .thread: return 0.3...0.9
        case .mix: return 0.15...0.6
        }
    }

    /// Quanto in fretta cambia la velocità: alto = scattante, basso = morbido
    var responsiveness: Double {
        switch self {
        case .bird: return 2.5
        case .mouse: return 9
        case .thread: return 1.8
        case .mix: return 4
        }
    }

    /// Ondeggiamento laterale: ampiezza (punti/s) e frequenza
    var wobble: (amplitude: Double, frequency: Double) {
        switch self {
        case .bird: return (60, 5)
        case .mouse: return (18, 16)
        case .thread: return (30, 1.6)
        case .mix: return (30, 4)
        }
    }
}

enum PreyMotion {
    /// Avvicina `current` a `target` in modo indipendente dal frame rate
    static func damp(_ current: CGPoint, toward target: CGPoint, rate: Double, dt: Double) -> CGPoint {
        let k = CGFloat(1 - exp(-rate * dt))
        return CGPoint(x: current.x + (target.x - current.x) * k,
                       y: current.y + (target.y - current.y) * k)
    }

    /// Ruota un angolo verso un altro seguendo la strada più corta
    static func lerpAngle(_ a: Double, _ b: Double, rate: Double, dt: Double) -> Double {
        var diff = (b - a).truncatingRemainder(dividingBy: 2 * .pi)
        if diff > .pi { diff -= 2 * .pi }
        if diff < -.pi { diff += 2 * .pi }
        return a + diff * (1 - exp(-rate * dt))
    }
}
