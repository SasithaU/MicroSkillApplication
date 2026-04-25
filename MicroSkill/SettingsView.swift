import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGoal") private var userGoal = ""
    
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
                
                HStack {
                    Text("Reminder Time")
                    Spacer()
                    Text("9:00 AM")
                        .foregroundColor(.secondary)
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
    }
    
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "isFirstTimeUser")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userGoal")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

