import SwiftUI

struct SettingsView: View {
    @Bindable var gameState: GameState
    @State private var section: SettingsSection = .gioco
    @Namespace private var switchNamespace

    private let labelFill = Color(red: 0.25, green: 0.45, blue: 0.62)

    var body: some View {
        ZStack {
            // 1. Back button (<) top-left with pure native Liquid Glass
            Button {
                SoundManager.shared.playSound(named: "ui_tap")
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    gameState.currentTab = .home
                }
            } label: {
                OutlinedText(
                    text: "<",
                    fontSize: 48,
                    fillColor: .white,
                    strokeColor: Color(white: 0.22),
                    lineWidth: 1.6
                )
                .frame(width: 98, height: 80)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
            .position(x: 249, y: 155)

            // 2. Real Liquid Glass Switch (Audio | Game) top-right with sliding glass thumb
            audioGameLiquidSwitch
                .position(x: 1110, y: 155)

            // 3. Main Liquid Glass Panel (Audio or Game)
            if section == .audio {
                audioPanel
                    .position(x: 683, y: 405)
            } else {
                giocoPanel
                    .position(x: 683, y: 505)
            }
        }
    }

    // MARK: - True Liquid Glass Sliding Switch (Audio | Game)
    private var audioGameLiquidSwitch: some View {
        let isGame = (section == .gioco)
        return ZStack(alignment: isGame ? .trailing : .leading) {
            // Sliding Liquid Glass Thumb Indicator
            Capsule(style: .continuous)
                .fill(Color.clear)
                .frame(width: 168, height: 70)
                .glassEffect(
                    .regular
                        .tint(Color(red: 0.22, green: 0.62, blue: 0.96).opacity(0.52))
                        .interactive(),
                    in: .capsule
                )
                .padding(5)

            // Labels row
            HStack(spacing: 0) {
                switchOptionButton(.audio, title: "Audio")
                switchOptionButton(.gioco, title: "Game")
            }
        }
        .frame(width: 346, height: 80)
        .glassEffect(.clear.interactive(), in: .capsule)
        .gesture(
            DragGesture(minimumDistance: 8)
                .onEnded { drag in
                    if drag.translation.width > 15 && section != .gioco {
                        SoundManager.shared.playSound(named: "ui_tap")
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.74)) {
                            section = .gioco
                        }
                    } else if drag.translation.width < -15 && section != .audio {
                        SoundManager.shared.playSound(named: "ui_tap")
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.74)) {
                            section = .audio
                        }
                    }
                }
        )
    }

    private func switchOptionButton(_ target: SettingsSection, title: String) -> some View {
        let selected = (section == target)
        return Button {
            guard section != target else { return }
            SoundManager.shared.playSound(named: "ui_tap")
            withAnimation(.spring(response: 0.32, dampingFraction: 0.74)) {
                section = target
            }
        } label: {
            OutlinedText(
                text: title,
                fontSize: 34,
                fillColor: selected ? .white : Color.white.opacity(0.78),
                strokeColor: Color(white: 0.22),
                lineWidth: 1.4
            )
            .scaleEffect(selected ? 1.04 : 0.96)
            .frame(width: 168, height: 70)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Audio Panel
    private var audioPanel: some View {
        HStack(spacing: 48) {
            settingLabelPill("Volume", fontSize: 38)
            sliderPill(value: $gameState.volume, range: 0.0...1.0) {
                SoundManager.shared.playSound(named: gameState.selectedPrey.soundName)
            }
        }
        .frame(width: 965, height: 186)
        .glassEffect(
            .regular.tint(Color(red: 0.55, green: 0.80, blue: 0.98).opacity(0.22)),
            in: .capsule
        )
    }

    // MARK: - Gioco Panel
    private var giocoPanel: some View {
        VStack(spacing: 34) {
            HStack(spacing: 48) {
                settingLabelPill("Speed", fontSize: 40)
                sliderPill(value: $gameState.speedMultiplier, range: 0.5...2.0, onEditingChanged: nil)
            }

            HStack(spacing: 48) {
                settingLabelPill("Time", fontSize: 40)
                segmentedValuePill(
                    idPrefix: "time",
                    values: [1, 3, 5, 10, 0],
                    selected: gameState.durationMinutes,
                    label: { $0 == 0 ? "∞" : "\($0)" }
                ) { val in
                    gameState.durationMinutes = val
                }
            }

            HStack(spacing: 48) {
                settingLabelPill("N.Target", fontSize: 34)
                segmentedValuePill(
                    idPrefix: "target",
                    values: [1, 2, 4, 6, 8],
                    selected: gameState.preyCount,
                    label: { "\($0)" }
                ) { val in
                    gameState.preyCount = val
                }
            }
        }
        .frame(width: 965, height: 460)
        .glassEffect(
            .regular.tint(Color(red: 0.55, green: 0.80, blue: 0.98).opacity(0.22)),
            in: .rect(cornerRadius: 72)
        )
    }

    // MARK: - Reusable Row Components
    private func settingLabelPill(_ title: String, fontSize: CGFloat) -> some View {
        OutlinedText(
            text: title,
            fontSize: fontSize,
            fillColor: labelFill,
            strokeColor: Color(white: 0.18),
            lineWidth: 1.4
        )
        .frame(width: 234, height: 88)
        .glassEffect(.regular, in: .capsule)
    }

    private func sliderPill(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        onEditingChanged: (() -> Void)?
    ) -> some View {
        PurpleGlassSlider(value: value, range: range, onEnded: onEditingChanged)
            .frame(width: 460, height: 44)
            .frame(width: 627, height: 88)
            .glassEffect(.regular, in: .capsule)
    }

    private func segmentedValuePill(
        idPrefix: String,
        values: [Int],
        selected: Int,
        label: @escaping (Int) -> String,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        let count = CGFloat(values.count)
        let itemWidth = 615.0 / count
        let selectedIndex = CGFloat(values.firstIndex(of: selected) ?? 0)

        return ZStack(alignment: .leading) {
            // Sliding Liquid Glass Thumb Indicator
            Capsule(style: .continuous)
                .fill(Color.clear)
                .frame(width: itemWidth - 4, height: 76)
                .glassEffect(
                    .regular
                        .tint(Color(red: 0.22, green: 0.62, blue: 0.96).opacity(0.52))
                        .interactive(),
                    in: .capsule
                )
                .offset(x: 8 + selectedIndex * itemWidth)

            HStack(spacing: 0) {
                ForEach(values, id: \.self) { val in
                    let isSelected = (val == selected)
                    Button {
                        SoundManager.shared.playSound(named: "ui_tap")
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.74)) {
                            onSelect(val)
                        }
                    } label: {
                        OutlinedText(
                            text: label(val),
                            fontSize: label(val) == "∞" ? 46 : 40,
                            fillColor: isSelected ? .white : Color.white.opacity(0.78),
                            strokeColor: Color(white: 0.22),
                            lineWidth: 1.5
                        )
                        .scaleEffect(isSelected ? 1.05 : 0.95)
                        .frame(width: itemWidth, height: 78)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(width: 627, height: 88)
        .glassEffect(.clear.interactive(), in: .capsule)
    }
}

/// Custom interactive Liquid Glass slider
struct PurpleGlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var onEnded: (() -> Void)? = nil

    private let purple = Color(red: 0.64, green: 0.20, blue: 0.96)

    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width)
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let clamped = max(0, min(1, progress))
            let thumbX = clamped * width

            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.white.opacity(0.65))
                    .frame(height: 10)

                // Active Purple Track
                Capsule()
                    .fill(purple)
                    .frame(width: max(10, thumbX), height: 10)

                // Liquid Glass Thumb Knob
                Circle()
                    .fill(purple.opacity(0.85))
                    .frame(width: 34, height: 34)
                    .glassEffect(.regular.tint(purple.opacity(0.45)).interactive(), in: .circle)
                    .offset(x: thumbX - 17)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let ratio = max(0, min(1, Double(drag.location.x / width)))
                        let raw = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
                        value = (raw * 20).rounded() / 20
                    }
                    .onEnded { _ in
                        onEnded?()
                    }
            )
        }
    }
}
