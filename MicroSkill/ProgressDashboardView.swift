import SwiftUI

struct ProgressDashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Progress Dashboard")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressDashboardView()
}

