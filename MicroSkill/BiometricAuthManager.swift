import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @Published var authError: String?

    private init() {}

    var canAuthenticate: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
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

    var biometricIconName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }

    func authenticate() {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        guard canAuthenticate else {
            authError = "Authentication is not available on this device."
            isAuthenticated = false
            return
        }

        let reason = "Secure your learning progress with \(biometricType)."

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    self.authError = nil
                } else {
                    self.isAuthenticated = false
                    self.authError = self.userFacingErrorMessage(from: error)
                }
            }
        }
    }

    func reset() {
        isAuthenticated = false
        authError = nil
    }

    private func userFacingErrorMessage(from error: Error?) -> String {
        guard let laError = error as? LAError else {
            return error?.localizedDescription ?? "Authentication failed."
        }

        switch laError.code {
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .userCancel:
            return "Authentication was canceled."
        case .userFallback:
            return "Please use your device passcode to continue."
        case .biometryNotAvailable:
            return "Biometric authentication is not available on this device."
        case .biometryNotEnrolled:
            return "No biometrics are enrolled. Please set up Face ID or Touch ID in Settings."
        case .biometryLockout:
            return "Biometrics are locked. Use your device passcode to unlock and try again."
        case .passcodeNotSet:
            return "A device passcode is required to enable authentication."
        case .systemCancel:
            return "Authentication was interrupted by the system. Please try again."
        default:
            return laError.localizedDescription
        }
    }
}


