import SwiftUI

struct GamePlayView: View {
    @Bindable var gameState: GameState
    
    @State private var exitHold: Double = 0   //0...1, cresce mentre tieni premuto
    @State private var preys: [PreyEntity] = []
    @State private var ripples: [PawRipple] = []
    @State private var particles: [CatchRewardParticle] = []
    @State private var gameTimer: Timer? = nil
    @State private var screenBounds: CGSize = .zero
    private let hudBandHeight: CGFloat = 110
    @State private var shakeProgress: CGFloat = 0
    @State private var isRunning = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AssetImageView(name: "clean_bg", contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .modifier(ShakeEffect(animatableData: shakeProgress))
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

                // Layer dei tocchi: sopra il gioco, sotto l'HUD
                touchLayer
                    .frame(width: geo.size.width, height: geo.size.height)

                VStack {
                    hud
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                screenBounds = geo.size
                setupGame()
                ScreenAwake.set(true)
                SoundManager.shared.playSound(named: "game_start")
            }
            .onChange(of: geo.size) { _, newSize in
                screenBounds = newSize
            }
            .onDisappear {
                stopGame()
                ScreenAwake.set(false)
            }
            #if os(iOS)
            .persistentSystemOverlays(.hidden)
            #endif
        }
    }

    @ViewBuilder
    private var touchLayer: some View {
        #if os(iOS)
        TouchSurface { point in
            handleTap(at: point)
        }
        #else
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { handleTap(at: $0.location) }
            )
        #endif
    }
    
    private var exitButton: some View {
        let ink = Color(red: 0.12, green: 0.20, blue: 0.32)
        let shape = Capsule(style: .continuous)
        return ZStack {
            // Riempimento che cresce mentre tieni premuto
            shape
                .fill(Color.red.opacity(0.55))
                .scaleEffect(x: exitHold, y: 1, anchor: .leading)

            Label("Tieni premuto per uscire", systemImage: "xmark")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(ink)
        }
        .padding(.horizontal, 26)
        .frame(height: 52)
        .clipShape(shape)
        .glassEffect(.regular.tint(Color.red.opacity(0.35)), in: shape)
        .contentShape(shape)
        .onLongPressGesture(
            minimumDuration: 1.5,
            maximumDistance: 40,
            perform: { exitGame() },
            onPressingChanged: { pressing in
                withAnimation(.linear(duration: pressing ? 1.5 : 0.25)) {
                    exitHold = pressing ? 1 : 0
                }
            }
        )
    }

    private func exitGame() {
        SoundManager.shared.playSound(named: GameSounds.uiTap)
        gameState.stopSession()
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
            
            exitButton
            
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
        SoundManager.shared.stopPreySounds()
        isRunning = true

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
        isRunning = false
        gameTimer?.invalidate()
        gameTimer = nil
        SoundManager.shared.stopAll()
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
        entity.angle = Double(atan2(h / 2 - startY, w / 2 - startX)) + Double.random(in: -0.4...0.4)
        entity.lastSoundTimer = Double.random(in: 5...9)
        preys.append(entity)
        
        SoundManager.shared.playPreySound(named: type.soundName, for: entity.id)
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
        for i in preys.indices {
            updatePrey(&preys[i], dt: dt, bounds: CGSize(width: w, height: h))
        }
    }
    
    private func updatePrey(_ p: inout PreyEntity, dt: Double, bounds: CGSize) {
        let type = p.type
        p.flutterTimer += dt
        
        // Fruscio ogni tanto
        p.lastSoundTimer -= dt
        if p.lastSoundTimer <= 0 {
            SoundManager.shared.playPreySound(named: p.type.soundName, for: p.id)
            p.lastSoundTimer = Double.random(in: 5...9)
        }
        
        // Ritmo di crociera: cambia da solo, a volte rallenta di colpo
        p.cruiseTimer -= dt
        if p.cruiseTimer <= 0 {
            p.cruiseFactor = Double.random(in: 0...1) < 0.25
            ? Double.random(in: 0.3...0.5)
            : Double.random(in: type.cruiseRange)
            p.cruiseTimer = Double.random(in: 0.8...2.5)
        }
        
        // Scatto (decollo per l'uccellino): raro e casuale
        if p.dashTimer > 0 {
            p.dashTimer -= dt
        } else if Double.random(in: 0...1) < type.dashChance * dt {
            p.dashTimer = Double.random(in: 0.35...0.8)
            p.dashFactor = Double.random(in: type.dashFactorRange)
        }
        
        // Pausa: a volte si blocca di colpo, con un piccolo scatto della testa
        if p.pauseTimer > 0 {
            p.pauseTimer -= dt
        } else if Double.random(in: 0...1) < type.pauseChance * dt {
            p.pauseTimer = Double.random(in: type.pauseRange)
            p.velocity = .zero                        // stop istantaneo, niente frenata
            p.angle += Double.random(in: -0.5...0.5)  // scatto della testa
        }
        let paused = p.pauseTimer > 0
        
        // Direzione: deriva morbida e continua, senza bersagli
        p.turnRate += Double.random(in: -1...1) * type.turnJitter * dt
        p.turnRate = min(max(p.turnRate, -type.maxTurnRate), type.maxTurnRate)
        p.turnRate *= exp(-0.8 * dt)
        p.angle += p.turnRate * dt
        
        // Vicino ai bordi, la preda gira verso il centro
        let m = type.margin
        let outside = p.position.x < m || p.position.x > bounds.width - m
        || p.position.y < m || p.position.y > bounds.height - m
        if outside {
            let toCenter = atan2(Double(bounds.height / 2 - p.position.y),
                                 Double(bounds.width / 2 - p.position.x))
            p.angle = PreyMotion.lerpAngle(p.angle, toCenter, rate: 3, dt: dt)
        }
        
        // Velocità desiderata: ritmo × scatto, zero in pausa
        let rush = p.dashTimer > 0 ? p.dashFactor : 1.0
        let speed = paused ? 0 : p.speed * p.cruiseFactor * rush
        let dir = CGPoint(x: CGFloat(cos(p.angle)), y: CGFloat(sin(p.angle)))
        var target = CGPoint(x: dir.x * CGFloat(speed), y: dir.y * CGFloat(speed))
        
        // Ondeggiamento laterale, più ampio durante il decollo
        if !paused {
            let wob = type.wobble
            let lift: Double = (type == .bird && p.dashTimer > 0) ? 2 : 1
            let sway = CGFloat(sin(p.flutterTimer * wob.frequency) * wob.amplitude * lift)
            target.x += -dir.y * sway
            target.y += dir.x * sway
        }
        
        // Inerzia: accelera e frena gradualmente
        p.velocity = PreyMotion.damp(p.velocity, toward: target, rate: type.responsiveness, dt: dt)
        p.position.x += p.velocity.x * CGFloat(dt)
        p.position.y += p.velocity.y * CGFloat(dt)
        
        // Sicurezza: resta sempre dentro lo schermo
        p.position.x = min(max(p.position.x, 20), bounds.width - 20)
        p.position.y = min(max(p.position.y, 20), bounds.height - 20)
    }
    
    private func handleTap(at point: CGPoint) {
        ripples.append(PawRipple(position: point))

        let catchRadius: CGFloat = 120
        let startleRadius: CGFloat = 240
        let lookAhead: CGFloat = 0.15   // secondi: dove sarà la preda tra un attimo

        var caughtIndex: Int? = nil
        var bestDistance = CGFloat.greatestFiniteMagnitude

        for (idx, p) in preys.enumerated() {
            let now = distance(p.position, point)
            let ahead = distance(
                CGPoint(x: p.position.x + p.velocity.x * lookAhead,
                        y: p.position.y + p.velocity.y * lookAhead),
                point
            )
            let d = min(now, ahead)

            if d < catchRadius && d < bestDistance {
                bestDistance = d
                caughtIndex = idx
            }
        }

        #if DEBUG
        let nearest = preys.map { distance($0.position, point) }.min() ?? -1
        print("Tocco a \(Int(point.x)),\(Int(point.y)): preda più vicina \(Int(nearest)) px")
        #endif

        if let idx = caughtIndex {
            catchPrey(at: idx)
        } else {
            // Tocco vicino ma non abbastanza: le prede vicine scattano via
            for idx in preys.indices where distance(preys[idx].position, point) < startleRadius {
                startle(idx, from: point)
            }
            SoundManager.shared.playSound(named: GameSounds.rustle)
        }
    }

    private func catchPrey(at idx: Int) {
        gameState.catCatches += 1
        let caught = preys[idx]
        SoundManager.shared.playSound(named: caught.type.popSound)
        Haptics.catchPaw()
        shakeScreen()

        let colors: [Color] = [.yellow, .orange, .cyan, .white, Color(red: 0.4, green: 0.85, blue: 1.0)]
        for _ in 0..<18 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 80...240)
            particles.append(CatchRewardParticle(
                position: caught.position,
                velocity: CGPoint(x: CGFloat(cos(angle)) * speed, y: CGFloat(sin(angle)) * speed),
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...16)
            ))
        }

        // Il verso della preda si ferma insieme a lei
        SoundManager.shared.stopPreySound(for: caught.id)
        preys.remove(at: idx)

        // Lo spawn successivo parte solo se la partita è ancora attiva
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if isRunning {
                spawnPrey()
            }
        }
    }

    private func startle(_ idx: Int, from point: CGPoint) {
        let p = preys[idx]
        let dx = p.position.x - point.x
        let dy = p.position.y - point.y
        let d = max(1, sqrt(dx * dx + dy * dy))

        preys[idx].angle = Double(atan2(dy, dx))
        preys[idx].pauseTimer = 0
        preys[idx].dashTimer = Double.random(in: 0.4...0.7)
        preys[idx].dashFactor = 2.0
        preys[idx].velocity = CGPoint(x: dx / d * 420, y: dy / d * 420)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func shakeScreen() {
        shakeProgress = 0
        DispatchQueue.main.async {
            withAnimation(.linear(duration: 0.4)) {
                shakeProgress = 1
            }
        }
    }
}
