import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var symbolScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Theme.heroGradient.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .blur(radius: 20)
                    
                    AppLogo.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .scaleEffect(symbolScale)
                        .premiumShadow()
                }
                
                VStack(spacing: 12) {
                    Text("Micro Skill")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.primary)
                        .tracking(1.5)
                    
                    Text("MASTER THE ESSENTIALS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                        .tracking(3)
                        .opacity(0.7)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                symbolScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            RootView()
        }
    }
}

#Preview {
    SplashView()
}
