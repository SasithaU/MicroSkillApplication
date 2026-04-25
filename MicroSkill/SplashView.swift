import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.15))
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(Theme.heroGradient)
                        .accessibilityLabel("Book icon")
                }
                
                Text("MicroSkill")
                    .font(Theme.largeTitle())
                    .foregroundStyle(Theme.primary)
                    .accessibilityLabel("Micro Skill app")
                
                Text("Learn something new every day")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Tagline: Learn something new every day")
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            OnboardingView()
        }
    }
}

#Preview {
    SplashView()
}
