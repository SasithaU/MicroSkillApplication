import SwiftUI

struct APISettingsView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var showSavedAlert = false
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.primary)
                        .padding()
                        .background(Circle().fill(Theme.primary.opacity(0.1)))
                    
                    Text("Gemini API Configuration")
                        .font(Theme.title())
                    
                    Text("Enter your Google Gemini API key to enable AI-powered learning path generation.")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("API KEY")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    SecureField("Paste your API key here", text: $apiKey)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.primary.opacity(0.3), lineWidth: 1))
                }
                
                // Guide Link
                Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Get a free key from Google AI Studio")
                    }
                    .font(Theme.caption())
                    .foregroundColor(Theme.primary)
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveKey) {
                    Text("Save API Key")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(apiKey.isEmpty)
                
                // Clear Button
                Button(action: {
                    apiKey = ""
                    store.geminiApiKey = ""
                    dismiss()
                }) {
                    Text("Clear Key")
                        .font(Theme.caption())
                        .foregroundColor(.red)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, Theme.padding)
        }
        .onAppear {
            apiKey = store.geminiApiKey
        }
        .navigationTitle("API Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Settings Saved", isPresented: $showSavedAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your Gemini API key has been updated and saved securely.")
        }
    }
    
    private func saveKey() {
        store.geminiApiKey = apiKey
        showSavedAlert = true
    }
}

#Preview {
    APISettingsView()
        .environmentObject(DataStore.shared)
}
