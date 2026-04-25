import WidgetKit
import SwiftUI

struct MicroSkillEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let nextLessonTitle: String
    let completedLessons: Int
    let totalLessons: Int
}

struct MicroSkillProvider: TimelineProvider {
    func placeholder(in context: Context) -> MicroSkillEntry {
        MicroSkillEntry(
            date: Date(),
            streak: 5,
            nextLessonTitle: "Intro to React",
            completedLessons: 3,
            totalLessons: 6
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MicroSkillEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MicroSkillEntry>) -> ()) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> MicroSkillEntry {
        let defaults = UserDefaults(suiteName: "group.com.microskill.app") ?? UserDefaults.standard
        let streak = defaults.integer(forKey: "widgetStreak")
        let completed = defaults.integer(forKey: "widgetCompletedLessons")
        let total = defaults.integer(forKey: "widgetTotalLessons")
        let nextTitle = defaults.string(forKey: "widgetNextLessonTitle") ?? "Start Learning"

        return MicroSkillEntry(
            date: Date(),
            streak: streak > 0 ? streak : 0,
            nextLessonTitle: nextTitle,
            completedLessons: completed,
            totalLessons: total > 0 ? total : 6
        )
    }
}

struct MicroSkillWidgetEntryView: View {
    var entry: MicroSkillProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(entry.streak) day streak")
                    .font(.caption)
                    .bold()
            }

            Text(entry.nextLessonTitle)
                .font(.footnote)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text("Tap to continue")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("\(entry.streak)")
                    .font(.title)
                    .bold()
                Text("Day Streak")
                    .font(.caption)
            }
            .frame(width: 80)

            VStack(alignment: .leading, spacing: 8) {
                Text("Next Lesson")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.nextLessonTitle)
                    .font(.headline)
                    .lineLimit(2)

                ProgressView(value: Double(entry.completedLessons), total: Double(entry.totalLessons))
                    .tint(.blue)
                Text("\(entry.completedLessons)/\(entry.totalLessons) completed")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct MicroSkillWidget: Widget {
    let kind: String = "MicroSkillWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MicroSkillProvider()) { entry in
            MicroSkillWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("MicroSkill Progress")
        .description("See your streak and next lesson at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


