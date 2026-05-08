import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedDay: DailyCompletion?
    
    private var dailyData: [DailyCompletion] {
        store.dailyCompletionCounts(forDays: 7).map {
            DailyCompletion(date: $0.date, count: $0.count, weekday: $0.weekday)
        }
    }
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Performance")
                            .font(Theme.largeTitle())
                        Text("Track your learning achievements")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    // Header Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            value: "\(store.completedLessonsCount)",
                            label: "Completed",
                            icon: "checkmark.circle.fill",
                            color: Theme.success
                        )
                        .accessibilityLabel("\(store.completedLessonsCount) lessons completed")
                        
                        StatCard(
                            value: "\(store.progress.streak)",
                            label: "Day Streak",
                            icon: "flame.fill",
                            color: .orange
                        )
                        .accessibilityLabel("\(store.progress.streak) day streak")
                        
                        StatCard(
                            value: "\(store.progress.totalPoints)",
                            label: "Total Points",
                            icon: "sparkles",
                            color: .yellow
                        )
                        .accessibilityLabel("\(store.progress.totalPoints) mastery points")
                        
                        StatCard(
                            value: "\(Int(Double(store.completedLessonsCount) / Double(max(store.totalLessonsCount, 1)) * 100))%",
                            label: "Global Progress",
                            icon: "chart.pie.fill",
                            color: Theme.primary
                        )
                        .accessibilityLabel("Global progress: \(Int(Double(store.completedLessonsCount) / Double(max(store.totalLessonsCount, 1)) * 100))%")
                    }
                    
                    // Weekly Activity Chart
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Weekly Activity")
                                .font(Theme.headline())
                            Spacer()
                            HStack(spacing: 4) {
                                Circle().fill(Theme.primary).frame(width: 8, height: 8)
                                Text("Lessons")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if dailyData.allSatisfy({ $0.count == 0 }) {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.3))
                                Text("No activity recorded yet")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 180)
                            .background(Color.primary.opacity(0.03))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Chart(dailyData) { day in
                                BarMark(
                                    x: .value("Day", day.weekday),
                                    y: .value("Lessons", day.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.primary, Theme.primary.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(8)
                            }
                            .frame(height: 200)
                            .chartYAxis(.hidden)
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let strValue = value.as(String.self) {
                                            Text(strValue.prefix(1))
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .accessibilityLabel("Weekly activity chart showing lessons completed each day")
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .premiumShadow()
                    
                    // Detailed Insights Link
                    NavigationLink(value: "insights") {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.accent.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "lightbulb.min.fill")
                                    .foregroundStyle(Theme.accent)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Learning Insights")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                                Text("Analyze your habits and patterns")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.primary.opacity(0.8))
                        }
                        .padding()
                        .glassCardStyle()
                    }
                    .buttonStyle(.plain)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Model for Chart
struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let weekday: String
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .premiumShadow()
    }
}

#Preview {
    NavigationStack {
        ProgressDashboardView()
            .environmentObject(DataStore.shared)
    }
}

#Preview {
    ProgressDashboardView()
        .environmentObject(DataStore.shared)
}
