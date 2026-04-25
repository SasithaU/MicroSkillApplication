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
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    // Header Stats
                    HStack(spacing: Theme.spacing) {
                        StatCard(
                            value: "\(store.completedLessonsCount)",
                            label: "Completed",
                            icon: "checkmark.circle.fill",
                            color: Theme.success
                        )
                        
                        StatCard(
                            value: "\(store.progress.streak)",
                            label: "Day Streak",
                            icon: "flame.fill",
                            color: Color.orange
                        )
                    }
                    
                    // Weekly Chart
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Last 7 Days")
                                .font(Theme.headline())
                            Spacer()
                            Text("\(dailyData.reduce(0) { $0 + $1.count }) lessons")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        if dailyData.allSatisfy({ $0.count == 0 }) {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.4))
                                Text("Complete lessons to see your progress chart")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 180)
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(Theme.cardCornerRadius)
                        } else {
                            Chart(dailyData) { day in
                                BarMark(
                                    x: .value("Day", day.weekday),
                                    y: .value("Lessons", day.count)
                                )
                                .foregroundStyle(day.count > 0 ? Theme.primary : Color.secondary.opacity(0.3))
                                .cornerRadius(6)
                                .annotation(position: .top) {
                                    if day.count > 0 {
                                        Text("\(day.count)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Theme.primary)
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let strValue = value.as(String.self) {
                                            Text(strValue.prefix(1))
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Overall Progress Ring
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Progress")
                            .font(Theme.headline())
                        
                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.15), lineWidth: 12)
                                    .frame(width: 100, height: 100)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(min(store.completedLessonsCount, store.totalLessonsCount)) / CGFloat(max(store.totalLessonsCount, 1)))
                                    .stroke(Theme.heroGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.8), value: store.completedLessonsCount)
                                
                                VStack(spacing: 2) {
                                    Text("\(store.completedLessonsCount)/\(store.totalLessonsCount)")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("lessons")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(store.totalLessonsCount - store.completedLessonsCount) lessons remaining")
                                    .font(Theme.body())
                                    .foregroundColor(.primary)
                                
                                Text("You're doing great! Keep the momentum going.")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Navigate to Insights
                    NavigationLink(destination: InsightsView()) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(Theme.accent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Detailed Insights")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                                Text("Best time, most active day, and more")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
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
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(Theme.caption())
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
    }
}

#Preview {
    ProgressDashboardView()
        .environmentObject(DataStore.shared)
}

