import SwiftUI

struct CategoriesView: View {
    let categories = ["Tech", "Productivity", "General Knowledge"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.spacing) {
                        Text("Browse Topics")
                            .font(Theme.largeTitle())
                            .foregroundStyle(Theme.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)

                        ForEach(categories, id: \.self) { category in
                            NavigationLink(value: category) {
                                CategoryCard(
                                    category: category,
                                    icon: categoryIcon(for: category),
                                    color: categoryColor(for: category)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(category) category. \(DummyData.lessons.filter { $0.category == category }.count) lessons available")
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Theme.padding)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { category in
                LessonListView(category: category)
            }
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
        case "Tech": return .indigo
        case "Productivity": return .cyan
        case "General Knowledge": return .purple
        default: return .blue
        }
    }
}

struct CategoryCard: View {
    let category: String
    let icon: String
    let color: Color

    private var lessonCount: Int {
        DummyData.lessons.filter { $0.category == category }.count
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }

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
        .padding()
        .cardStyle()
    }
}

#Preview {
    CategoriesView()
}

