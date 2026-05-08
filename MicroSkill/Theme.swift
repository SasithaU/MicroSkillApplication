import SwiftUI
import UIKit

enum Theme {
    // MARK: - Colors
    static let primary = Color.accentColor
    static let primaryDark = Color(red: 0.02, green: 0.22, blue: 0.50)
    static let accent = Color.teal
    static let accentSoft = Color.mint.opacity(0.75)
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let elevatedBackground = Color(.tertiarySystemGroupedBackground)
    static let separator = Color(.separator).opacity(0.28)
    static let success = Color.green
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // MARK: - Gradients
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primary.opacity(0.86)],
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
    static let cardCornerRadius: CGFloat = 18
    static let controlCornerRadius: CGFloat = 12
    static let cardShadowRadius: CGFloat = 14
    static let cardShadowOpacity: CGFloat = 0.06
    static let spacing: CGFloat = 16
    
    // MARK: - Typography (Dynamic Type aware)
    static func largeTitle() -> Font {
        .system(.largeTitle, design: .default, weight: .bold)
    }
    
    static func title() -> Font {
        .system(.title2, design: .default, weight: .semibold)
    }
    
    static func headline() -> Font {
        .system(.headline, design: .default, weight: .semibold)
    }
    
    static func body() -> Font {
        .system(.body, design: .default, weight: .regular)
    }
    
    static func caption() -> Font {
        .system(.caption, design: .default, weight: .medium)
    }
}

// MARK: - Reusable Card Style
struct CardStyle: ViewModifier {
    private var highContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
    }

    private var reduceTransparencyEnabled: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }

    func body(content: Content) -> some View {
        content
            .padding(Theme.padding)
            .background(
                (reduceTransparencyEnabled ? Theme.cardBackground : Color.clear),
                in: RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
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
                        highContrastEnabled ? Color.primary.opacity(0.65) : Theme.separator,
                        lineWidth: highContrastEnabled ? 1.2 : 0.5
                    )
            )
            .shadow(
                color: Color.black.opacity(Theme.cardShadowOpacity),
                radius: reduceTransparencyEnabled ? 0 : Theme.cardShadowRadius,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Compact Icon Tile
struct IconTile: View {
    private var highContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
    }

    private var reduceTransparencyEnabled: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }

    let systemName: String
    let color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(highContrastEnabled ? Color.primary : color)
            .frame(width: 44, height: 44)
            .background(
                (highContrastEnabled || reduceTransparencyEnabled) ? Color(.systemGray5) : color.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        highContrastEnabled ? Color.primary.opacity(0.65) : Color.clear,
                        lineWidth: highContrastEnabled ? 1 : 0
                    )
            )
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonBody(configuration: configuration)
    }
}

private struct PrimaryButtonBody: View {
    let configuration: ButtonStyle.Configuration

    private var reduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    var body: some View {
        configuration.label
            .font(Theme.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Theme.heroGradient
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.controlCornerRadius, style: .continuous))
            .scaleEffect(reduceMotionEnabled ? 1 : (configuration.isPressed ? 0.98 : 1.0))
            .animation(reduceMotionEnabled ? nil : .snappy(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Selection Card Style
struct SelectionCardStyle: ButtonStyle {
    let isSelected: Bool

    private var reduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    private var differentiateWithoutColorEnabled: Bool {
        UIAccessibility.shouldDifferentiateWithoutColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(isSelected ? Theme.primary.opacity(0.12) : Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(isSelected ? Theme.primary : Theme.separator, lineWidth: isSelected ? 1.5 : 0.5)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected && differentiateWithoutColorEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.primary)
                        .padding(10)
                }
            }
            .shadow(
                color: Color.black.opacity(Theme.cardShadowOpacity),
                radius: Theme.cardShadowRadius,
                x: 0,
                y: 2
            )
            .scaleEffect(reduceMotionEnabled ? 1 : (configuration.isPressed ? 0.98 : 1.0))
            .animation(reduceMotionEnabled ? nil : .snappy(duration: 0.18), value: configuration.isPressed)
    }
}


