import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Saved Lessons")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Saved")
        }
    }
}

#Preview {
    SavedView()
}

