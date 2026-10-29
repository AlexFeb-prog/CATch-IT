import SwiftUI

struct SettingsView: View {
    @Bindable var gameState: GameState
    @State private var section: SettingsSection = .gioco

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

            // 2. Audio | Game segmented switch top-right with pure native Liquid Glass
            HStack(spacing: 4) {
                segmentButton(.audio, title: "Audio")
                segmentButton(.gioco, title: "Game")
            }
            .padding(4)
            .glassEffect(.regular, in: .capsule)
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

    // MARK: - Segmented Switch Button
    private func segmentButton(_ target: SettingsSection, title: String) -> some View {
        let selected = section == target
        return Button {
            SoundManager.shared.playSound(named: "ui_tap")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                section = target
            }
        } label: {
            OutlinedText(
                text: title,
                fontSize: 36,
                fillColor: .white,
                strokeColor: Color(white: 0.25),
                lineWidth: 1.4
            )
            .frame(width: 168, height: 72)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(
            selected
                ? .regular.tint(Color(red: 0.28, green: 0.65, blue: 0.92).opacity(0.45)).interactive()
                : .clear.interactive(),
            in: .capsule
        )
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
        values: [Int],
        selected: Int,
        label: @escaping (Int) -> String,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        HStack(spacing: 4) {
            ForEach(values, id: \.self) { val in
                let isSelected = (val == selected)
                Button {
                    SoundManager.shared.playSound(named: "ui_tap")
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        onSelect(val)
                    }
                } label: {
                    OutlinedText(
                        text: label(val),
                        fontSize: label(val) == "∞" ? 46 : 40,
                        fillColor: .white,
                        strokeColor: Color(white: 0.22),
                        lineWidth: 1.5
                    )
                    .frame(width: (615.0 / CGFloat(values.count)) - 4, height: 78)
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .glassEffect(
                    isSelected
                        ? .regular.tint(Color(red: 0.28, green: 0.65, blue: 0.92).opacity(0.45)).interactive()
                        : .clear.interactive(),
                    in: .capsule
                )
            }
        }
        .padding(.horizontal, 6)
        .frame(width: 627, height: 88)
        .glassEffect(.regular, in: .capsule)
    }
}

/// Custom interactive purple slider matching Option_Audio & Option_Gioco
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
                // Background White Track
                Capsule()
                    .fill(Color.white.opacity(0.92))
                    .frame(height: 10)
                    .shadow(color: Color.black.opacity(0.12), radius: 2, y: 2)

                // Active Purple Track
                Capsule()
                    .fill(purple)
                    .frame(width: max(10, thumbX), height: 10)

                // Thumb Knob
                Circle()
                    .fill(purple)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 4, y: 2)
                    .offset(x: thumbX - 15)
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
