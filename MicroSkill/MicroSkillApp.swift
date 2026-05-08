import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationManager.shared.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case NotificationManager.ActionID.ok, UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
            break
        case NotificationManager.ActionID.startLesson:
            NotificationCenter.default.post(name: .startLessonFromNotification, object: nil)
        case NotificationManager.ActionID.remindLater:
            NotificationManager.shared.scheduleDailyReminder(at: Calendar.current.component(.hour, from: Date().addingTimeInterval(3600)), minute: 0)
        default:
            break
        }
        completionHandler()
    }
}

@main
struct MicroSkillApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(DataStore.shared)
                .environmentObject(LocationManager.shared)
        }
    }
}

extension Notification.Name {
    static let startLessonFromNotification = Notification.Name("startLessonFromNotification")
}
