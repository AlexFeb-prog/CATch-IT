import SwiftUI

struct SettingsView: View {
    @Bindable var gameState: GameState
    @State private var section: SettingsSection = .gioco

    private let labelFill = Color(red: 0.25, green: 0.45, blue: 0.62)
    private let pillBg = Color(red: 0.78, green: 0.86, blue: 0.94).opacity(0.72)

    var body: some View {
        ZStack {
            // 1. Back button (<) top-left with real Liquid Glass and high-contrast outline
            Button {
                SoundManager.shared.playSound(named: "ui_tap")
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    gameState.currentTab = .home
                }
            } label: {
                ZStack {
                    Capsule(style: .continuous)
                        .fill(pillBg)
                        .glassEffect(.regular, in: Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color(white: 0.28), lineWidth: 1.8)
                        )
                        .shadow(color: Color.black.opacity(0.20), radius: 5, y: 3)
                        .frame(width: 98, height: 80)

                    OutlinedText(
                        text: "<",
                        fontSize: 48,
                        fillColor: .white,
                        strokeColor: Color(white: 0.22),
                        lineWidth: 1.6
                    )
                }
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .position(x: 249, y: 155)

            // 2. Audio | Game segmented switch top-right with real Liquid Glass
            HStack(spacing: 0) {
                segmentButton(.audio, title: "Audio", isLeft: true)
                segmentButton(.gioco, title: "Game", isLeft: false)
            }
            .background(
                Capsule(style: .continuous)
                    .fill(Color(red: 0.82, green: 0.89, blue: 0.95).opacity(0.72))
                    .glassEffect(.regular, in: Capsule(style: .continuous))
            )
            .clipShape(Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color(white: 0.22), lineWidth: 1.8)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)
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
    private func segmentButton(_ target: SettingsSection, title: String, isLeft: Bool) -> some View {
        let selected = section == target
        return Button {
            SoundManager.shared.playSound(named: "ui_tap")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                section = target
            }
        } label: {
            ZStack {
                if selected {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.68, blue: 0.86).opacity(0.88),
                                    Color(red: 0.24, green: 0.50, blue: 0.70).opacity(0.92)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                OutlinedText(
                    text: title,
                    fontSize: 36,
                    fillColor: .white,
                    strokeColor: Color(white: 0.25),
                    lineWidth: 1.4
                )
            }
            .frame(width: 172, height: 80)
            .overlay(alignment: isLeft ? .trailing : .leading) {
                Rectangle()
                    .fill(Color(white: 0.25).opacity(0.5))
                    .frame(width: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Audio Panel
    private var audioPanel: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(Color(red: 0.77, green: 0.89, blue: 1.0).opacity(0.76))
                .glassEffect(.regular, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.24), radius: 10, y: 5)
                .frame(width: 965, height: 186)

            HStack(spacing: 48) {
                settingLabelPill("Volume", fontSize: 38)
                sliderPill(value: $gameState.volume, range: 0.0...1.0) {
                    SoundManager.shared.playSound(named: gameState.selectedPrey.soundName)
                }
            }
        }
    }

    // MARK: - Gioco Panel
    private var giocoPanel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(Color(red: 0.77, green: 0.89, blue: 1.0).opacity(0.76))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 100, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.24), radius: 10, y: 5)
                .frame(width: 965, height: 460)

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
        }
    }

    // MARK: - Reusable Row Components
    private func settingLabelPill(_ title: String, fontSize: CGFloat) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(pillBg)
                .glassEffect(.regular, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color(white: 0.28), lineWidth: 1.4)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 4, y: 2)
                .frame(width: 234, height: 88)

            OutlinedText(
                text: title,
                fontSize: fontSize,
                fillColor: labelFill,
                strokeColor: Color(white: 0.18),
                lineWidth: 1.4
            )
        }
    }

    private func sliderPill(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        onEditingChanged: (() -> Void)?
    ) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(pillBg)
                .glassEffect(.regular, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color(white: 0.28), lineWidth: 1.4)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 4, y: 2)
                .frame(width: 627, height: 88)

            PurpleGlassSlider(value: value, range: range, onEnded: onEditingChanged)
                .frame(width: 460, height: 44)
        }
    }

    private func segmentedValuePill(
        values: [Int],
        selected: Int,
        label: @escaping (Int) -> String,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(pillBg)
                .glassEffect(.regular, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color(white: 0.28), lineWidth: 1.4)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 4, y: 2)
                .frame(width: 627, height: 88)

            HStack(spacing: 0) {
                ForEach(values, id: \.self) { val in
                    let isSelected = (val == selected)
                    Button {
                        SoundManager.shared.playSound(named: "ui_tap")
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            onSelect(val)
                        }
                    } label: {
                        ZStack {
                            Capsule(style: .continuous)
                                .fill(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [
                                                Color(red: 0.42, green: 0.68, blue: 0.86).opacity(0.88),
                                                Color(red: 0.24, green: 0.50, blue: 0.70).opacity(0.92)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        : LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.25),
                                                Color(red: 0.75, green: 0.85, blue: 0.95).opacity(0.35)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(
                                            isSelected ? Color.black : Color(white: 0.28),
                                            lineWidth: isSelected ? 2.8 : 1.3
                                        )
                                )

                            OutlinedText(
                                text: label(val),
                                fontSize: label(val) == "∞" ? 46 : 40,
                                fillColor: .white,
                                strokeColor: Color(white: 0.22),
                                lineWidth: 1.5
                            )
                        }
                        .frame(width: 627.0 / CGFloat(values.count), height: 86)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// Custom interactive purple slider matching Option_Audio & Option_Gioco in Immagini 2
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
