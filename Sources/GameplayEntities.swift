import SwiftUI

struct PreyEntity: Identifiable {
    let id = UUID()
    var type: PreyType
    var position: CGPoint
    var targetPosition: CGPoint
    var velocity: CGPoint = .zero
    var angle: Double = 0.0
    var scale: CGFloat = 1.0
    
    // Predatory behavioral state machine
    var isHiding: Bool = false
    var hideTimer: Double = 0.0
    var pauseTimer: Double = 0.0
    var speed: Double = 220.0
    
    // Locomotion nuances
    var flutterTimer: Double = 0.0
    var wingFlapAngle: Double = 0.0
    var threadTrail: [CGPoint] = []
    var scuttleStep: Int = 0
    var dashCooldown: Double = 0.0
    
    var lastSoundTimer: Double = 0.0
}

struct PawRipple: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 0.2
    var opacity: Double = 1.0
}

struct CatchRewardParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var color: Color
    var opacity: Double = 1.0
    var size: CGFloat = 10.0
}
