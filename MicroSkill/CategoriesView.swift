import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var store: DataStore
    let categories = ["Tech", "Productivity", "General Knowledge"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.spacing) {
                        ForEach(categories, id: \.self) { category in
                            NavigationLink(destination: LessonListView(category: category)) {
                                CategoryCard(
                                    category: category,
                                    icon: categoryIcon(for: category),
                                    color: categoryColor(for: category),
                                    lessonCount: store.lessons.filter { $0.category == category }.count
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(category) category. \(store.lessons.filter { $0.category == category }.count) lessons available")
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Theme.padding)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    func categoryIcon(for category: String) -> String {
        switch category {
        case "Tech": return "laptopcomputer"
        case "Productivity": return "checkmark.seal.fill"
        case "General Knowledge": return "lightbulb.fill"
        default: return "book.fill"
        }
    }

    func categoryColor(for category: String) -> Color {
        switch category {
        case "Tech": return Theme.primary
        case "Productivity": return Theme.accent
        case "General Knowledge": return .orange
        default: return .blue
        }
    }
}

struct CategoryCard: View {
    let category: String
    let icon: String
    let color: Color
    let lessonCount: Int

    var body: some View {
        HStack(spacing: 16) {
            IconTile(systemName: icon, color: color)

            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(Theme.headline())
                    .foregroundColor(.primary)

                Text("\(lessonCount) lessons")
                    .font(Theme.caption())
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }
}

#Preview {
    CategoriesView()
}
