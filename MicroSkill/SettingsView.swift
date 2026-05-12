import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled", store: UserDefaults(suiteName: "group.com.microskill.app")) private var notificationsEnabled = false
    @AppStorage("notificationHour", store: UserDefaults(suiteName: "group.com.microskill.app")) private var notificationHour = 9
    @AppStorage("notificationMinute", store: UserDefaults(suiteName: "group.com.microskill.app")) private var notificationMinute = 0
    @AppStorage("activeSubject", store: UserDefaults(suiteName: "group.com.microskill.app")) private var userGoal = ""
    @AppStorage("locationEnabled", store: UserDefaults(suiteName: "group.com.microskill.app")) private var locationEnabled = false
    @AppStorage("appAccessibilityHighContrast", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityReduceMotion = false
    @AppStorage("appAccessibilityDifferentiateWithoutColor", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityDifferentiateWithoutColor = false
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var authManager = BiometricAuthManager.shared
    @EnvironmentObject var store: DataStore
    @State private var showLogoutConfirmation = false
    @State private var showResetConfirmation = false
    private let goalOptions = ["Tech Skills", "Productivity", "General Knowledge"]
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            List {
                Section("Account") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(store.progress.userName ?? "Not set")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Learning Focus", selection: $userGoal) {
                        ForEach(goalOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
                
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
                        
                        HStack {
                            Image(systemName: "clock.badge.checkmark.fill")
                                .foregroundColor(notificationManager.isAuthorized ? .green : .secondary)
                            Text(nextReminderText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
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
                .listRowBackground(Color.white.opacity(0.05))
                
                Section("Security") {
                    Toggle("Require Face ID to Unlock", isOn: $authManager.isBiometricAuthEnabled)
                        .disabled(!authManager.canAuthenticate)
                        .accessibilityHint("Requires biometric authentication whenever the app is opened.")

                    HStack {
                        Text("Status")
                        Spacer()
                        Image(systemName: authManager.canAuthenticate ? "checkmark.shield.fill" : "xmark.shield")
                            .foregroundColor(authManager.canAuthenticate ? .green : .secondary)
                        Text(authManager.canAuthenticate ? "Available" : "Unavailable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(authManager.biometricType)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Biometric authentication status. \(authManager.canAuthenticate ? "Available" : "Not available"). Type: \(authManager.biometricType).")
                }
                .listRowBackground(Color.white.opacity(0.05))

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
                .listRowBackground(Color.white.opacity(0.05))
                
                Section("Contextual Learning") {
                    Toggle("Location-Aware Suggestions", isOn: $locationEnabled)
                        .onChange(of: locationEnabled) { _, newValue in
                            if newValue {
                                locationManager.requestAuthorization()
                                locationManager.startTracking()
                            } else {
                                locationManager.stopTracking()
                            }
                        }
                        .accessibilityHint("Uses location context to suggest relevant lessons.")
                    
                    if locationEnabled {
                        NavigationLink(destination: LocationsManagementView()) {
                            HStack {
                                Text("Manage Learning Locations")
                                Spacer()
                                Text("\(locationManager.savedLocations.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if locationManager.detectedContext != "unknown" {
                            HStack {
                                Text("Current Context")
                                Spacer()
                                Text(locationManager.detectedLocationName ?? locationManager.detectedContext.capitalized)
                                    .foregroundColor(.blue)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Current context: \(locationManager.detectedLocationName ?? locationManager.detectedContext.capitalized).")
                        }
                    }
                    
                    if !locationManager.canUseLocation && locationEnabled {
                        Text("Location services are not authorized. Please enable them in Settings.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
                
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
                .listRowBackground(Color.white.opacity(0.05))
                
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
                
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset Journey")
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .alert("Log Out?", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    logout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will end your current session and return you to the onboarding screen. Your progress will be reset.")
            }
            .alert("Reset Journey?", isPresented: $showResetConfirmation) {
                Button("Reset Everything", role: .destructive) {
                    resetOnboarding()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently erase all your progress and lessons. This action cannot be undone.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationManager.checkAuthorization()
        }
    }
    
    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = notificationHour
                components.minute = notificationMinute
                return calendar.date(from: components) ?? Date()
            },
            set: { newDate in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: newDate)
                let newHour = components.hour ?? 9
                let newMinute = components.minute ?? 0
                
                // Only update if changed to avoid redundant scheduling
                if newHour != notificationHour || newMinute != notificationMinute {
                    notificationHour = newHour
                    notificationMinute = newMinute
                    
                    if notificationsEnabled {
                        notificationManager.scheduleDailyReminder(at: notificationHour, minute: notificationMinute)
                    }
                }
            }
        )
    }
    
    private var nextReminderText: String {
        if !notificationManager.isAuthorized {
            return "Notifications disabled in system settings"
        }
        
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.hour = notificationHour
        components.minute = notificationMinute
        components.second = 0
        
        guard let scheduledDate = calendar.date(from: components) else { return "Next reminder scheduled" }
        
        let finalDate = scheduledDate > now ? scheduledDate : calendar.date(byAdding: .day, value: 1, to: scheduledDate) ?? scheduledDate
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        
        return "Next reminder: \(formatter.string(from: finalDate))"
    }
    
    private func resetOnboarding() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.microskill.app") ?? UserDefaults.standard
        sharedDefaults.set(false, forKey: "isFirstTimeUser")
        sharedDefaults.removeObject(forKey: "activeSubject")
        BiometricAuthManager.shared.reset()
        notificationManager.cancelAllNotifications()
        DataStore.shared.activeSubject = nil // Ensure DataStore is in sync
        DataStore.shared.resetAllData() // Clear Core Data
    }
    
    private func logout() {
        // For local-only app, logout is essentially resetting the session
        resetOnboarding()
    }
}
struct LocationsManagementView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showAddSheet = false
    @State private var newLocationName = ""
    @State private var selectedCategory = "Tech"
    private let categories = ["Tech", "Productivity", "General Knowledge", "Creative", "Business"]
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            List {
                Section {
                    Text("Add your favorite learning spots. When you're at these locations, MicroSkill will suggest relevant topics.")
                        .font(Theme.caption())
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                Section("My Learning Spots") {
                    if locationManager.savedLocations.isEmpty {
                        Text("No locations set yet.")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(locationManager.savedLocations) { location in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.name)
                                        .font(Theme.body())
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Image(systemName: "tag.fill")
                                            .font(.system(size: 10))
                                        Text(location.recommendedCategory)
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundColor(Theme.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.primary.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                
                                Spacer()
                                
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(Theme.primary)
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: locationManager.removeLocation)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Learning Locations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                ZStack {
                    Theme.background.ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LOCATION NAME")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            TextField("e.g. My Favorite Cafe, Library", text: $newLocationName)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("RECOMMENDED CATEGORY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Text("MicroSkill will use your current GPS coordinate for this spot.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        Button {
                            locationManager.addLocation(name: newLocationName, category: selectedCategory)
                            newLocationName = ""
                            showAddSheet = false
                        } label: {
                            Text("Set Current Location")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(newLocationName.isEmpty)
                    }
                    .padding(24)
                }
                .navigationTitle("Add New Spot")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showAddSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
