import SwiftUI

struct HomeView: View {
    @Bindable var gameState: GameState
    @State private var catBounce: CGFloat = 0
    @State private var playPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 1. Play Button with pure native Apple Liquid Glass (placed below cat paws in Z-order)
            Button {
                SoundManager.shared.playSound(named: "catch_pop")
                gameState.startSession()
            } label: {
                HStack(spacing: 22) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 80, weight: .bold))
                    Text("Play")
                        .font(.system(size: 98, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
                .frame(width: 662, height: 231)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(
                .regular
                    .tint(Color(red: 0.35, green: 0.78, blue: 0.98).opacity(0.32))
                    .interactive(),
                in: .capsule
            )
            .scaleEffect(playPulse)
            .position(x: 683, y: 355)

            // 2. Cat on top: anchored flush into the top window border (top edge tucked beyond y=0)
            AssetImageView(name: "cat_peeking")
                .frame(width: 534, height: 337)
                .position(x: 683, y: 155 + catBounce)
                .allowsHitTesting(false)

            // 3. Logo CATch It!
            AssetImageView(name: "logo_catchit")
                .frame(width: 861, height: 214)
                .position(x: 683, y: 610)
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
