import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DataStore
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userGoal") private var userGoal = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing) {
                        // Profile Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.regularMaterial)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.separator, lineWidth: 0.5)
                                    )
                                
                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 32, weight: .semibold, design: .default))
                                    .foregroundColor(Theme.primary)
                            }
                            
                            Text(userName)
                                .font(Theme.title())
                                .foregroundColor(.primary)
                            
                            if !userGoal.isEmpty {
                                Text(userGoal)
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 16)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing) {
                            StatCard(
                                value: "\(store.completedLessonsCount)",
                                label: "Lessons Done",
                                icon: "checkmark.circle.fill",
                                color: Theme.success
                            )
                            
                            StatCard(
                                value: "\(store.savedLessons.count)",
                                label: "Saved",
                                icon: "bookmark.fill",
                                color: Theme.primary
                            )
                            
                            StatCard(
                                value: "\(store.progress.streak)",
                                label: "Day Streak",
                                icon: "flame.fill",
                                color: Color.orange
                            )
                            
                            StatCard(
                                value: "\(store.totalStudyTimeMinutes())m",
                                label: "Study Time",
                                icon: "clock.fill",
                                color: Theme.accent
                            )
                        }
                        
                        // Settings Link
                        NavigationLink(destination: SettingsView()) {
                            HStack(spacing: 12) {
                                IconTile(systemName: "gearshape.fill", color: .secondary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Settings")
                                        .font(Theme.headline())
                                        .foregroundColor(.primary)
                                    
                                    Text("Notifications, account, and more")
                                        .font(Theme.caption())
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Settings. Notifications, account, and more")
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataStore.shared)
}
