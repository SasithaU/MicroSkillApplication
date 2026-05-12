import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var userName: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var profileImageData: Data? = nil
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.primary, lineWidth: 2))
                                    .premiumShadow()
                            } else {
                                Circle()
                                    .fill(Theme.primary.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(Theme.primary)
                                    )
                                    .premiumShadow()
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Theme.primary)
                                    .clipShape(Circle())
                                    .offset(x: 40, y: 40)
                            }
                        }
                        .padding(.top, 40)
                        
                        Text("Edit Profile")
                            .font(Theme.title())
                    }
                    
                    // Stats Summary
                    HStack(spacing: 20) {
                        statView(title: "Lessons", value: "\(store.progress.completedLessons)", icon: "book.fill")
                        statView(title: "Streak", value: "\(store.progress.streak)d", icon: "flame.fill")
                        statView(title: "Points", value: "\(store.progress.totalPoints)", icon: "star.fill")
                    }
                    .padding(.horizontal)
                    
                    // Form Section
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NAME")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your name", text: $userName)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: HomeDestination.settings) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .onAppear {
            userName = store.progress.userName ?? ""
            if let data = store.progress.profileImageData, let uiImage = UIImage(data: data) {
                profileImage = Image(uiImage: uiImage)
                profileImageData = data
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImageData = data
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
    
    private func statView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
            Text(value)
                .font(.system(size: 18, weight: .bold))
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCardStyle()
    }
    
    private func saveProfile() {
        store.updateProfile(name: userName, imageData: profileImageData)
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataStore.shared)
}
