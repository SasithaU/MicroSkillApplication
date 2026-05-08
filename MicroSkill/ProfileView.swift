import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DataStore
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userGoal") private var userGoal = ""
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.heroGradient.opacity(0.1))
                                .frame(width: 100, height: 100)
                                .blur(radius: 10)
                            
                            Text(userName.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.primary)
                                .frame(width: 100, height: 100)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Theme.primary.opacity(0.2), lineWidth: 1))
                                .premiumShadow()
                        }
                        
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(Theme.title())
                                .foregroundColor(.primary)
                            
                            if !userGoal.isEmpty {
                                Text(userGoal)
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            value: "\(store.completedLessonsCount)",
                            label: "Completed",
                            icon: "checkmark.seal.fill",
                            color: Theme.success
                        )
                        
                        StatCard(
                            value: "\(store.savedLessons.count)",
                            label: "Saved Items",
                            icon: "bookmark.fill",
                            color: Theme.primary
                        )
                        
                        StatCard(
                            value: "\(store.progress.streak)",
                            label: "Current Streak",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            value: "\(store.totalStudyTimeMinutes())m",
                            label: "Learning Time",
                            icon: "clock.fill",
                            color: Theme.accent
                        )
                    }
                    
                    // Options List
                    VStack(spacing: 12) {
                        NavigationLink(value: "settings") {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.secondary.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "gearshape.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Preferences")
                                        .font(Theme.headline())
                                        .foregroundColor(.primary)
                                    Text("Notifications, account, and more")
                                        .font(Theme.caption())
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .glassCardStyle()
                        }
                        .buttonStyle(.plain)
                        
                        Button(role: .destructive) {
                            showingLogoutAlert = true
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "power")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                
                                Text("Sign Out")
                                    .font(Theme.headline())
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.red.opacity(0.1), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .alert("Sign Out", isPresented: $showingLogoutAlert) {
                            Button("Sign Out", role: .destructive) {
                                BiometricAuthManager.shared.reset()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to sign out? Your progress is synced to your device.")
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(DataStore.shared)
    }
}
