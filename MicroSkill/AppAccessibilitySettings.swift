import SwiftUI

struct AppAccessibilitySettings {
    var highContrast: Bool = false
    var reduceTransparency: Bool = false
    var reduceMotion: Bool = false
    var differentiateWithoutColor: Bool = false
}

private struct AppAccessibilitySettingsKey: EnvironmentKey {
    static let defaultValue = AppAccessibilitySettings()
}

extension EnvironmentValues {
    var appAccessibilitySettings: AppAccessibilitySettings {
        get { self[AppAccessibilitySettingsKey.self] }
        set { self[AppAccessibilitySettingsKey.self] = newValue }
    }
}
