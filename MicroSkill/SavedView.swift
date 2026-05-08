import SwiftUI

struct SavedView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            if store.savedLessons.isEmpty {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.1))
                            .frame(width: 120, height: 120)
                        Image(systemName: "bookmark.slash.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.primary.opacity(0.4))
                    }
                    
                    VStack(spacing: 8) {
                        Text("No Bookmarks Yet")
                            .font(Theme.title())
                        Text("Save interesting lessons to read them later.")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Saved Lessons")
                                .font(Theme.largeTitle())
                            Text("Your curated library of micro-skills")
                                .font(Theme.body())
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            ForEach(store.savedLessons) { lesson in
                                NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                    SavedLessonRow(lesson: lesson)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Saved lesson: \(lesson.title) in \(lesson.category)")
                                .accessibilityHint("Double tap to read this lesson")
                            }
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavedLessonRow: View {
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(lesson.category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primary.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            store.toggleSaveLesson(lesson)
                        }
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Theme.primary)
                            .font(.title3)
                    }
                    .accessibilityLabel("Remove from saved")
                    .accessibilityHint("Double tap to remove this lesson from your bookmarks")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(Theme.headline())
                        .foregroundColor(.primary)
                    
                    Text(lesson.content)
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .lineSpacing(4)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .premiumShadow()
    }
}

#Preview {
    NavigationStack {
        SavedView()
            .environmentObject(DataStore.shared)
    }
}
