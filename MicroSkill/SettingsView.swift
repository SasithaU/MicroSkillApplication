import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGoal") private var userGoal = ""
    @AppStorage("locationEnabled") private var locationEnabled = false
    @AppStorage("appAccessibilityHighContrast") private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion") private var appAccessibilityReduceMotion = false
    @AppStorage("appAccessibilityDifferentiateWithoutColor") private var appAccessibilityDifferentiateWithoutColor = false
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    private let goalOptions = ["Tech Skills", "Productivity", "General Knowledge"]
    
    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(userName.isEmpty ? "Not set" : userName)
                        .foregroundColor(.secondary)
                }
                
                Picker("Learning Focus", selection: $userGoal) {
                    ForEach(goalOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            }
            
            Section("Preferences") {
                Toggle("Daily Reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            notificationManager.requestAuthorizationAndScheduleDailyReminder(at: notificationHour, minute: notificationMinute)
                        } else {
                            notificationManager.cancelAllNotifications()
                        }
                    }
                    .accessibilityHint("Turns daily learning reminder notifications on or off.")
                
                if notificationsEnabled {
                    DatePicker("Reminder Time",
                               selection: reminderTimeBinding,
                               displayedComponents: .hourAndMinute)
                    .accessibilityHint("Select the time for daily reminders.")
                }
                
                if !notificationManager.isAuthorized && notificationsEnabled {
                    Text("Notifications are not authorized. Please enable them in Settings.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Button("Send Test Notification") {
                    if notificationManager.isAuthorized {
                        notificationManager.scheduleTestInteractiveNotification()
                    } else {
                        notificationManager.requestAuthorization { granted in
                            if granted {
                                notificationManager.scheduleTestInteractiveNotification()
                            }
                        }
                    }
                }
                .accessibilityHint("Sends a sample reminder notification.")
            }
            
            Section("Security") {
                HStack {
                    Text("Biometric Authentication")
                    Spacer()
                    Image(systemName: BiometricAuthManager.shared.canAuthenticate ? "checkmark.shield.fill" : "xmark.shield")
                        .foregroundColor(BiometricAuthManager.shared.canAuthenticate ? .green : .secondary)
                    Text(BiometricAuthManager.shared.canAuthenticate ? "Available" : "Unavailable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(BiometricAuthManager.shared.biometricType)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Biometric authentication status. \(BiometricAuthManager.shared.canAuthenticate ? "Available" : "Not available"). Type: \(BiometricAuthManager.shared.biometricType).")
            }

            Section("Accessibility") {
                Toggle("High Contrast", isOn: $appAccessibilityHighContrast)
                    .accessibilityHint("Increases contrast for cards and icons.")

                Toggle("Reduce Transparency", isOn: $appAccessibilityReduceTransparency)
                    .accessibilityHint("Uses solid card backgrounds instead of translucent materials.")

                Toggle("Reduce Motion", isOn: $appAccessibilityReduceMotion)
                    .accessibilityHint("Reduces motion effects in interactive components.")

                Toggle("Differentiate Without Color", isOn: $appAccessibilityDifferentiateWithoutColor)
                    .accessibilityHint("Adds non-color indicators for selected states.")
            }
            
            Section("Location") {
                Toggle("Context-Aware Lessons", isOn: $locationEnabled)
                    .onChange(of: locationEnabled) { _, newValue in
                        if newValue {
                            locationManager.requestAuthorization()
                            locationManager.startTracking()
                        } else {
                            locationManager.stopTracking()
                        }
                    }
                    .accessibilityHint("Uses location context to suggest relevant lessons.")
                
                if locationManager.canUseLocation && locationEnabled {
                    Button(locationManager.hasHomeLocation ? "Update Home Location" : "Set Home Location") {
                        locationManager.setHomeLocation()
                    }
                    
                    if locationManager.hasHomeLocation {
                        Button("Clear Home Location") {
                            locationManager.clearHomeLocation()
                        }
                        .tint(.red)
                    }
                    
                    Button(locationManager.hasUniversityLocation ? "Update University Location" : "Set University Location") {
                        locationManager.setUniversityLocation()
                    }
                    
                    if locationManager.hasUniversityLocation {
                        Button("Clear University Location") {
                            locationManager.clearUniversityLocation()
                        }
                        .tint(.red)
                    }
                    
                    if locationManager.detectedContext != "unknown" {
                        HStack {
                            Text("Current Context")
                            Spacer()
                            Text(locationManager.detectedContext.capitalized)
                                .foregroundColor(.blue)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Current context: \(locationManager.detectedContext.capitalized).")
                    }
                }
                
                if !locationManager.canUseLocation && locationEnabled {
                    Text("Location services are not authorized. Please enable them in Settings.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.04.25")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(role: .destructive) {
                    resetOnboarding()
                } label: {
                    Text("Reset Onboarding")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            notificationManager.checkAuthorization()
        }
    }
    
    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = notificationHour
                components.minute = notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                notificationHour = components.hour ?? 9
                notificationMinute = components.minute ?? 0
                if notificationsEnabled {
                    notificationManager.scheduleDailyReminder(at: notificationHour, minute: notificationMinute)
                }
            }
        )
    }
    
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "isFirstTimeUser")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userGoal")
        BiometricAuthManager.shared.reset()
        notificationManager.cancelAllNotifications()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
