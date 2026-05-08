import SwiftUI
import UIKit

enum Theme {
    // MARK: - Colors
    static let primary = Color(red: 0.24, green: 0.35, blue: 0.95) // Vibrant Indigo
    static let primaryLight = Color(red: 0.45, green: 0.55, blue: 1.0)
    static let accent = Color(red: 0.0, green: 0.82, blue: 0.73) // Sophisticated Teal
    static let secondaryAccent = Color(red: 1.0, green: 0.48, blue: 0.41) // Coral
    static let success = Color(red: 0.15, green: 0.70, blue: 0.35)
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let separator = Color(.separator)
    
    // MARK: - Gradients
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accent.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var coralGradient: LinearGradient {
        LinearGradient(
            colors: [secondaryAccent, secondaryAccent.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Layout
    static let padding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 22
    static let controlCornerRadius: CGFloat = 14
    static let cardShadowRadius: CGFloat = 12
    static let cardShadowOpacity: CGFloat = 0.08
    static let spacing: CGFloat = 16
    
    // MARK: - Typography
    static func largeTitle() -> Font {
        .system(.largeTitle, design: .rounded, weight: .bold)
    }
    
    static func title() -> Font {
        .system(.title2, design: .rounded, weight: .bold)
    }
    
    static func headline() -> Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }
    
    static func body() -> Font {
        .system(.body, design: .rounded, weight: .regular)
    }
    
    static func caption() -> Font {
        .system(.caption, design: .rounded, weight: .semibold)
    }
}

// MARK: - Reusable Card Style
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appAccessibilitySettings) private var appAccessibility
    @AppStorage("appAccessibilityHighContrast") private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false

    private var highContrastEnabled: Bool {
        appAccessibility.highContrast || appAccessibilityHighContrast || UIAccessibility.isDarkerSystemColorsEnabled
    }

    private var reduceTransparencyEnabled: Bool {
        appAccessibility.reduceTransparency || appAccessibilityReduceTransparency || UIAccessibility.isReduceTransparencyEnabled
    }

    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(reduceTransparencyEnabled ? Theme.cardBackground : Color.clear)
            )
            .background {
                if !reduceTransparencyEnabled {
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                        .fill(.regularMaterial)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(
                        highContrastEnabled ? Color.primary.opacity(0.8) : Color.white.opacity(colorScheme == .dark ? 0.08 : 0.4),
                        lineWidth: highContrastEnabled ? 1.5 : 0.5
                    )
            )
            .shadow(
                color: Color.black.opacity(Theme.cardShadowOpacity),
                radius: Theme.cardShadowRadius,
                x: 0,
                y: 8
            )
    }
}

// MARK: - Glass Card Style
struct GlassCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appAccessibilitySettings) private var appAccessibility
    @AppStorage("appAccessibilityHighContrast") private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false

    private var highContrastEnabled: Bool {
        appAccessibility.highContrast || appAccessibilityHighContrast || UIAccessibility.isDarkerSystemColorsEnabled
    }

    private var reduceTransparencyEnabled: Bool {
        appAccessibility.reduceTransparency || appAccessibilityReduceTransparency || UIAccessibility.isReduceTransparencyEnabled
    }

    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(reduceTransparencyEnabled ? Theme.cardBackground : Color.clear)
            .background {
                if !reduceTransparencyEnabled {
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(
                        highContrastEnabled ? Color.primary.opacity(0.8) : Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                        lineWidth: highContrastEnabled ? 1.5 : 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func glassCardStyle() -> some View {
        modifier(GlassCardStyle())
    }
    
    func premiumShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Background
struct PremiumBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appAccessibilitySettings) private var appAccessibility
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion") private var appAccessibilityReduceMotion = false

    private var reduceTransparencyEnabled: Bool {
        appAccessibility.reduceTransparency || appAccessibilityReduceTransparency || UIAccessibility.isReduceTransparencyEnabled
    }

    private var reduceMotionEnabled: Bool {
        appAccessibility.reduceMotion || appAccessibilityReduceMotion || UIAccessibility.isReduceMotionEnabled
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if !reduceTransparencyEnabled {
                if colorScheme == .light {
                    Circle()
                        .fill(Theme.primary.opacity(0.12))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: -150, y: -250)
                    
                    Circle()
                        .fill(Theme.accent.opacity(0.12))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: 150, y: 300)
                } else {
                    Circle()
                        .fill(Theme.primary.opacity(0.08))
                        .frame(width: 500, height: 500)
                        .blur(radius: 100)
                        .offset(x: -200, y: -300)
                }
            }
        }
        .accessibilityHidden(true) // Background should not be seen by screen readers
    }
}

// MARK: - Compact Icon Tile
struct IconTile: View {
    let systemName: String
    let color: Color
    var isGlass: Bool = false
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(color)
            .frame(width: 48, height: 48)
            .background {
                if isGlass {
                    Circle()
                        .fill(.thinMaterial)
                        .overlay(Circle().stroke(color.opacity(0.2), lineWidth: 0.5))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.15))
                }
            }
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
                    .opacity(configuration.isPressed ? 0.9 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.controlCornerRadius, style: .continuous))
            .premiumShadow()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Selection Card Style
struct SelectionCardStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(isSelected ? Theme.primary.opacity(0.1) : Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}
