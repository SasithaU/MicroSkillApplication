import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var navigationPathHome = NavigationPath()
    @State private var navigationPathProgress = NavigationPath()
    @State private var navigationPathSaved = NavigationPath()
    @State private var navigationPathProfile = NavigationPath()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPathHome) {
                HomeView()
                    .navigationDestination(for: HomeDestination.self) { destination in
                        switch destination {
                        case .learningPath:
                            LearningPathView()
                        case .lessonDetail(let lesson, let categoryLimit):
                            LessonDetailView(lesson: lesson, categoryLimit: categoryLimit)
                        case .categories:
                            CategoriesView()
                        case .profile:
                            ProfileView()
                        case .settings:
                            SettingsView()
                        case .locations:
                            LearningLocationsView()
                        }
                    }
                    .navigationDestination(for: Lesson.self) { lesson in
                        LessonDetailView(lesson: lesson, categoryLimit: nil)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            

            NavigationStack(path: $navigationPathProgress) {
                ProgressDashboardView()
                    .navigationDestination(for: String.self) { destination in
                        if destination == "insights" {
                            InsightsView()
                        }
                    }
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }
            .tag(1)
            
            NavigationStack(path: $navigationPathSaved) {
                SavedView()
                    .navigationDestination(for: String.self) { destination in
                        // Handle navigation destinations for Saved
                    }
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
            .tag(2)
            
            NavigationStack(path: $navigationPathProfile) {
                ProfileView()
                    .navigationDestination(for: HomeDestination.self) { destination in
                        if destination == .settings {
                            SettingsView()
                        }
                    }
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        .tint(Theme.primary)
        .onChange(of: selectedTab) { oldValue, newValue in
            // Reset navigation when switching tabs
            resetNavigationForTab(newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: .startLessonFromNotification)) { _ in
            handleStartLessonDeepLink()
        }
    }
    
    private func handleStartLessonDeepLink() {
        // Switch to Home tab
        selectedTab = 0
        // Clear existing path
        navigationPathHome = NavigationPath()
        
        // Find first uncompleted lesson
        if let nextLesson = DataStore.shared.lessons.first(where: { !$0.isCompleted }) {
            // Delay slightly to ensure tab switch animation is smooth
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                navigationPathHome.append(nextLesson)
            }
        }
    }
    
    private func resetNavigationForTab(_ tab: Int) {
        switch tab {
        case 0:
            navigationPathHome = NavigationPath()
        case 1:
            navigationPathProgress = NavigationPath()
        case 2:
            navigationPathSaved = NavigationPath()
        case 3:
            navigationPathProfile = NavigationPath()
        default:
            break
        }
    }
}

#Preview {
    MainTabView()
}
