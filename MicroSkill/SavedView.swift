import SwiftUI

struct SavedView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if store.savedLessons.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.4))
                        
                        Text("No Saved Lessons")
                            .font(Theme.headline())
                            .foregroundColor(.primary)
                        
                        Text("Bookmark lessons while learning to access them quickly here.")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: Theme.spacing) {
                            Text("\(store.savedLessons.count) saved")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(store.savedLessons) { lesson in
                                NavigationLink(value: lesson) {
                                    SavedLessonRow(lesson: lesson)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Saved lesson: \(lesson.title) in \(lesson.category)")
                            }
                        }
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, 8)
                    }
                    .navigationDestination(for: Lesson.self) { lesson in
                        LessonDetailView(lesson: lesson)
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Saved Lesson Row

struct SavedLessonRow: View {
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.category)
                    .font(Theme.caption())
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Theme.primary.opacity(0.12))
                    .cornerRadius(6)
                
                Text(lesson.title)
                    .font(Theme.headline())
                    .foregroundColor(.primary)
                
                Text(lesson.content)
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                store.toggleSaveLesson(lesson)
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.title3)
                    .foregroundColor(Theme.primary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    SavedView()
        .environmentObject(DataStore.shared)
}

