import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGoal") private var userGoal = ""
    @AppStorage("locationEnabled") private var locationEnabled = false
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(userName.isEmpty ? "Not set" : userName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Goal")
                    Spacer()
                    Text(userGoal.isEmpty ? "Not set" : userGoal)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Preferences") {
                Toggle("Daily Reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            notificationManager.requestAuthorization()
                            notificationManager.scheduleDailyReminder(at: notificationHour, minute: notificationMinute)
                        } else {
                            notificationManager.cancelAllNotifications()
                        }
                    }
                
                if notificationsEnabled {
                    DatePicker("Reminder Time",
                               selection: reminderTimeBinding,
                               displayedComponents: .hourAndMinute)
                }
                
                if !notificationManager.isAuthorized && notificationsEnabled {
                    Text("Notifications are not authorized. Please enable them in Settings.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Section("Security") {
                HStack {
                    Text("Biometric Authentication")
                    Spacer()
                    Image(systemName: BiometricAuthManager.shared.canAuthenticate ? "checkmark.shield.fill" : "xmark.shield")
                        .foregroundColor(BiometricAuthManager.shared.canAuthenticate ? .green : .secondary)
                    Text(BiometricAuthManager.shared.biometricType)
                        .foregroundColor(.secondary)
                }
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

