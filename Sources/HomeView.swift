import SwiftUI

struct HomeView: View {
    @Bindable var gameState: GameState
    @State private var catBounce: CGFloat = 0
    @State private var playPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 1. Play Button with Liquid Glass and original pastel sky-blue colors (placed below cat paws in Z-order)
            Button {
                SoundManager.shared.playSound(named: "catch_pop")
                gameState.startSession()
            } label: {
                HStack(spacing: 28) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 80, weight: .bold))
                    Text("Play")
                        .font(.system(size: 98, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .offset(y: 12)
                .frame(width: 662, height: 231)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.70, green: 0.90, blue: 0.99).opacity(0.78),
                                    Color(red: 0.56, green: 0.84, blue: 0.98).opacity(0.68)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .glassEffect(.regular, in: Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.95), Color.white.opacity(0.35)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                        .shadow(color: Color(red: 0.15, green: 0.35, blue: 0.55).opacity(0.22), radius: 16, y: 8)
                )
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .scaleEffect(playPulse)
            .position(x: 683, y: 368)

            // 2. Cat on top: centered visually over the Play button and attached flush to the top border
            AssetImageView(name: "cat_peeking")
                .frame(width: 534, height: 337)
                .position(x: 677, y: 164 + catBounce)
                .allowsHitTesting(false)

            // 3. Logo CATch It
            AssetImageView(name: "logo_catchit")
                .frame(width: 861, height: 214)
                .position(x: 683, y: 617)
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                catBounce = 4
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                playPulse = 1.02
            }
        }
    }
}
