import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var isAuthenticated = false
    @Published var authError: String?
    
    private let context = LAContext()
    
    private init() {}
    
    var canAuthenticate: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var biometricType: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometric"
        }
    }
    
    func authenticate() {
        guard canAuthenticate else {
            authError = "Biometric authentication is not available on this device."
            isAuthenticated = true // Fallback: allow access
            return
        }
        
        let reason = "Secure your learning progress with \(biometricType)."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.authError = nil
                } else {
                    self.isAuthenticated = false
                    self.authError = error?.localizedDescription ?? "Authentication failed"
                }
            }
        }
    }
    
    func reset() {
        isAuthenticated = false
        authError = nil
    }
}


