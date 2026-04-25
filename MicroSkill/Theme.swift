import SwiftUI

enum Theme {
    // MARK: - Colors
    static let primary = Color.indigo
    static let primaryDark = Color(red: 0.24, green: 0.20, blue: 0.60)
    static let accent = Color.cyan
    static let accentSoft = Color.purple.opacity(0.7)
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let success = Color.green
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // MARK: - Gradients
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardBackground, cardBackground.opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Layout
    static let padding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowOpacity: CGFloat = 0.08
    static let spacing: CGFloat = 16
    
    // MARK: - Typography (Dynamic Type aware)
    static func largeTitle() -> Font {
        .system(.largeTitle, design: .rounded, weight: .bold)
    }
    
    static func title() -> Font {
        .system(.title, design: .rounded, weight: .bold)
    }
    
    static func headline() -> Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }
    
    static func body() -> Font {
        .system(.body, design: .rounded, weight: .regular)
    }
    
    static func caption() -> Font {
        .system(.caption, design: .rounded, weight: .medium)
    }
}

// MARK: - Reusable Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cardCornerRadius)
            .shadow(
                color: Color.black.opacity(Theme.cardShadowOpacity),
                radius: Theme.cardShadowRadius,
                x: 0,
                y: 4
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Theme.heroGradient
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .cornerRadius(Theme.cardCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Selection Card Style
struct SelectionCardStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(isSelected ? Theme.primary.opacity(0.12) : Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: Color.black.opacity(Theme.cardShadowOpacity),
                radius: Theme.cardShadowRadius,
                x: 0,
                y: 2
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
