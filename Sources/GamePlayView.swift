import SwiftUI

struct GamePlayView: View {
    @Bindable var gameState: GameState
    
    @State private var preys: [PreyEntity] = []
    @State private var ripples: [PawRipple] = []
    @State private var particles: [CatchRewardParticle] = []
    @State private var gameTimer: Timer? = nil
    @State private var screenBounds: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AssetImageView(name: "clean_bg", contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()

                ForEach(ripples) { r in
                    Circle()
                        .stroke(Color.white.opacity(r.opacity * 0.8), lineWidth: 4)
                        .frame(width: 80 * r.scale, height: 80 * r.scale)
                        .position(r.position)
                }

                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .opacity(p.opacity)
                        .position(p.position)
                }

                ForEach(preys) { prey in
                    PreySpriteView(prey: prey)
                        .position(prey.position)
                        .allowsHitTesting(false)
                }

                VStack {
                    hud
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                SpatialTapGesture(count: 1)
                    .onEnded { location in
                        handleTap(at: location.location)
                    }
            )
            .onAppear {
                screenBounds = geo.size
                setupGame()
            }
            .onChange(of: geo.size) { _, newSize in
                screenBounds = newSize
            }
            .onDisappear {
                stopGame()
            }
        }
    }
    
    private var hud: some View {
        let ink = Color(red: 0.12, green: 0.20, blue: 0.32)
        return HStack(spacing: 16) {
            HStack(spacing: 10) {
                AssetImageView(name: "icon_paw").frame(width: 28, height: 28)
                Text("\(gameState.catCatches) Prede")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(ink)
            }
            .padding(.horizontal, 22).frame(height: 52)
            .glassEffect(.regular, in: Capsule(style: .continuous))

            Spacer()

            if gameState.durationMinutes > 0 {
                Label(formatTime(gameState.sessionTimeRemaining), systemImage: "timer")
                    .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(ink)
                    .padding(.horizontal, 22).frame(height: 52)
                    .glassEffect(.regular, in: Capsule(style: .continuous))
            }

            Button {
                SoundManager.shared.playSound(named: "ui_tap")
                gameState.stopSession()
            } label: {
                Label("Esci", systemImage: "xmark")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(ink)
                    .padding(.horizontal, 26).frame(height: 52)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(Color.red.opacity(0.35)).interactive(), in: Capsule(style: .continuous))
        }
        .padding(.horizontal, 28)
        #if os(macOS)
        .padding(.top, 40)
        #else
        .padding(.top, 16)
        #endif
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let s = max(0, Int(seconds))
        let m = s / 60
        let rem = s % 60
        return String(format: "%d:%02d", m, rem)
    }
    
    private func setupGame() {
        preys.removeAll()
        let count = max(1, gameState.preyCount)
        for _ in 0..<count {
            spawnPrey()
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            updatePhysics(dt: 1.0 / 60.0)
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func spawnPrey() {
        let type: PreyType
        if gameState.selectedPrey == .mix {
            let options: [PreyType] = [.bird, .mouse, .thread]
            type = options.randomElement() ?? .mouse
        } else {
            type = gameState.selectedPrey
        }
        
        let w = max(500, screenBounds.width)
        let h = max(400, screenBounds.height)
        
        // Spawn along peripheral edges (cats notice periphery first)
        let startX: CGFloat
        let startY: CGFloat
        if Bool.random() {
            startX = Bool.random() ? 50 : (w - 50)
            startY = CGFloat.random(in: 100...(h - 100))
        } else {
            startX = CGFloat.random(in: 100...(w - 100))
            startY = Bool.random() ? 50 : (h - 50)
        }
        
        let baseSpeed: Double
        switch type {
        case .bird: baseSpeed = 240.0
        case .mouse: baseSpeed = 290.0 // Mice have fast dashes
        case .thread: baseSpeed = 190.0
        case .mix: baseSpeed = 240.0
        }
        
        var entity = PreyEntity(
            type: type,
            position: CGPoint(x: startX, y: startY),
            targetPosition: CGPoint(x: w / 2, y: h / 2),
            speed: baseSpeed * gameState.speedMultiplier
        )
        entity.threadTrail = [entity.position]
        preys.append(entity)
        
        SoundManager.shared.playSound(named: type.soundName)
    }
    
    private func updatePhysics(dt: Double) {
        let w = screenBounds.width > 0 ? screenBounds.width : 1024
        let h = screenBounds.height > 0 ? screenBounds.height : 768
        
        if gameState.durationMinutes > 0 && gameState.sessionTimeRemaining > 0 {
            gameState.sessionTimeRemaining -= dt
            if gameState.sessionTimeRemaining <= 0 {
                gameState.stopSession()
                return
            }
        }
        
        // Ripples
        for i in (0..<ripples.count).reversed() {
            ripples[i].scale += CGFloat(dt * 2.5)
            ripples[i].opacity -= dt * 1.6
            if ripples[i].opacity <= 0 {
                ripples.remove(at: i)
            }
        }
        
        // Particles
        for i in (0..<particles.count).reversed() {
            particles[i].position.x += particles[i].velocity.x * CGFloat(dt)
            particles[i].position.y += particles[i].velocity.y * CGFloat(dt)
            particles[i].opacity -= dt * 1.8
            if particles[i].opacity <= 0 {
                particles.remove(at: i)
            }
        }
        
        // Prey ethological locomotion
        for i in 0..<preys.count {
            var p = preys[i]
            
            // Sound cue (subtle rustle/flutter/skitter)
            p.lastSoundTimer += dt
            if p.lastSoundTimer > Double.random(in: 5.0...9.0) {
                p.lastSoundTimer = 0
                SoundManager.shared.playSound(named: p.type.soundName)
            }
            
            // 1. MOUSE BEHAVIOR: Scurry-Stop-Freeze-Scurry
            if p.type == .mouse {
                if p.pauseTimer > 0 {
                    p.pauseTimer -= dt
                    preys[i] = p
                    continue
                }
                
                p.flutterTimer += dt
                let dx = p.targetPosition.x - p.position.x
                let dy = p.targetPosition.y - p.position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < 25.0 {
                    // Mouse pauses (alert posture)
                    p.pauseTimer = Double.random(in: 0.6...1.5)
                    // Then dashes to a new peripheral cover/burrow
                    let margin: CGFloat = 70.0
                    p.targetPosition = CGPoint(
                        x: CGFloat.random(in: margin...(w - margin)),
                        y: CGFloat.random(in: margin...(h - margin))
                    )
                    // High sprint speed
                    p.speed = Double.random(in: 280...400) * gameState.speedMultiplier
                } else {
                    let dirX = dx / dist
                    let dirY = dy / dist
                    let step = p.speed * dt
                    p.position.x += CGFloat(dirX * step)
                    p.position.y += CGFloat(dirY * step)
                    p.angle = atan2(dy, dx)
                }
            }
            
            // 2. BIRD BEHAVIOR: Swooping arcs, fluttering, sudden landing
            else if p.type == .bird {
                if p.pauseTimer > 0 {
                    p.pauseTimer -= dt
                    preys[i] = p
                    continue
                }
                
                p.flutterTimer += dt
                let dx = p.targetPosition.x - p.position.x
                let dy = p.targetPosition.y - p.position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < 40.0 {
                    if Double.random(in: 0...1) < 0.4 {
                        p.pauseTimer = Double.random(in: 0.4...0.9) // brief perch/hop
                    }
                    let margin: CGFloat = 80.0
                    p.targetPosition = CGPoint(
                        x: CGFloat.random(in: margin...(w - margin)),
                        y: CGFloat.random(in: margin...(h - margin))
                    )
                    p.speed = Double.random(in: 200...290) * gameState.speedMultiplier
                } else {
                    let dirX = dx / dist
                    let dirY = dy / dist
                    let step = p.speed * dt
                    p.position.x += CGFloat(dirX * step)
                    p.position.y += CGFloat(dirY * step)
                    p.angle = atan2(dy, dx) + sin(p.flutterTimer * 8.0) * 0.15
                }
            }
            
            // 3. THREAD BEHAVIOR: Smooth curvilinear dragging + intermittent stop-and-tug
            else if p.type == .thread {
                if p.pauseTimer > 0 {
                    p.pauseTimer -= dt
                    preys[i] = p
                    continue
                }
                
                p.flutterTimer += dt
                let dx = p.targetPosition.x - p.position.x
                let dy = p.targetPosition.y - p.position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < 30.0 {
                    if Double.random(in: 0...1) < 0.35 {
                        p.pauseTimer = Double.random(in: 0.3...0.8) // pause between tugs
                    }
                    let margin: CGFloat = 90.0
                    p.targetPosition = CGPoint(
                        x: CGFloat.random(in: margin...(w - margin)),
                        y: CGFloat.random(in: margin...(h - margin))
                    )
                    p.speed = Double.random(in: 160...240) * gameState.speedMultiplier
                } else {
                    let dirX = dx / dist
                    let dirY = dy / dist
                    let step = p.speed * dt
                    p.position.x += CGFloat(dirX * step)
                    p.position.y += CGFloat(dirY * step)
                    p.angle = atan2(dy, dx)
                }
            }
            
            // 4. MIX / DEFAULT
            else {
                p.flutterTimer += dt
                let dx = p.targetPosition.x - p.position.x
                let dy = p.targetPosition.y - p.position.y
                let dist = sqrt(dx * dx + dy * dy)
                if dist < 30.0 {
                    p.targetPosition = CGPoint(
                        x: CGFloat.random(in: 80...(w - 80)),
                        y: CGFloat.random(in: 80...(h - 80))
                    )
                } else {
                    let step = p.speed * dt
                    p.position.x += CGFloat((dx / dist) * step)
                    p.position.y += CGFloat((dy / dist) * step)
                    p.angle = atan2(dy, dx)
                }
            }
            
            preys[i] = p
        }
    }
    
    private func handleTap(at point: CGPoint) {
        ripples.append(PawRipple(position: point))
        
        var caughtIndex: Int? = nil
        for (idx, p) in preys.enumerated() {
            let dx = p.position.x - point.x
            let dy = p.position.y - point.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist < 95.0 {
                caughtIndex = idx
                break
            } else if dist < 240.0 {
                // Near-miss startles prey into fleeing immediately
                let w = screenBounds.width > 0 ? screenBounds.width : 1024
                let h = screenBounds.height > 0 ? screenBounds.height : 768
                preys[idx].pauseTimer = 0
                let fleeX = max(80, min(w - 80, p.position.x + (dx / max(1, dist)) * 320))
                let fleeY = max(80, min(h - 80, p.position.y + (dy / max(1, dist)) * 320))
                preys[idx].targetPosition = CGPoint(x: fleeX, y: fleeY)
                preys[idx].speed = 360.0 * gameState.speedMultiplier
            }
        }
        
        if let idx = caughtIndex {
            gameState.catCatches += 1
            let caught = preys[idx]
            // Tactile muffled thud sound
            SoundManager.shared.playSound(named: "catch_pop")
            
            for _ in 0..<18 {
                let angle = Double.random(in: 0...(2 * .pi))
                let speed = CGFloat.random(in: 80...240)
                let vel = CGPoint(x: cos(angle) * speed, y: sin(angle) * speed)
                let colors: [Color] = [.yellow, .orange, .cyan, .white, Color(red: 0.4, green: 0.85, blue: 1.0)]
                particles.append(CatchRewardParticle(
                    position: caught.position,
                    velocity: vel,
                    color: colors.randomElement() ?? .yellow,
                    size: CGFloat.random(in: 8...16)
                ))
            }
            
            preys.remove(at: idx)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                spawnPrey()
            }
        } else {
            SoundManager.shared.playSound(named: "ambient_rustle")
        }
    }
}
