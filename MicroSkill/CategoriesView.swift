import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var store: DataStore
    let categories = ["Tech", "Productivity", "General Knowledge"]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explore Skills")
                            .font(Theme.largeTitle())
                        Text("Choose a category to start your journey")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            NavigationLink(value: category) {
                                CategoryGridCard(
                                    category: category,
                                    icon: categoryIcon(for: category),
                                    gradient: categoryGradient(for: category),
                                    lessonCount: store.lessons.filter { $0.category == category }.count
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(category) category, \(store.lessons.filter { $0.category == category }.count) lessons")
                            .accessibilityHint("Double tap to explore lessons in \(category)")
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

    func categoryIcon(for category: String) -> String {
        switch category {
        case "Tech": return "laptopcomputer"
        case "Productivity": return "timer"
        case "General Knowledge": return "globe.americas.fill"
        default: return "book.fill"
        }
    }

    func categoryGradient(for category: String) -> LinearGradient {
        switch category {
        case "Tech": return Theme.heroGradient
        case "Productivity": return Theme.accentGradient
        case "General Knowledge": return Theme.coralGradient
        default: return Theme.heroGradient
        }
    }
}

struct CategoryGridCard: View {
    let category: String
    let icon: String
    let gradient: LinearGradient
    let lessonCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(gradient.opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(gradient)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(Theme.headline())
                    .foregroundColor(.primary)
                
                Text("\(lessonCount) Lessons")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white.opacity(0.02))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
        )
        .premiumShadow()
    }
}

#Preview {
    NavigationStack {
        CategoriesView()
            .environmentObject(DataStore.shared)
    }
}
