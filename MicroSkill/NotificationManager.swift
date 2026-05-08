import UserNotifications
import Foundation
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private enum NotificationID {
        static let dailyReminder = "daily-reminder"
        static let contextualReminder = "contextual-reminder"
        static let testReminder = "test-interactive-reminder"
    }
    
    private enum CategoryID {
        static let dailyReminder = "DAILY_REMINDER"
    }
    
    enum ActionID {
        static let ok = "OK"
        static let startLesson = "START_LESSON"
        static let remindLater = "REMIND_LATER"
    }
    
    private init() {
        configure()
    }
    
    func configure() {
        registerNotificationCategories()
        checkAuthorization()
    }
    
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("Notification auth error: \(error)")
                }
                completion?(granted)
            }
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let status = settings.authorizationStatus == .authorized
                if self.isAuthorized != status {
                    self.isAuthorized = status
                    print("Notification authorization status updated: \(status)")
                }
            }
        }
    }
    
    func registerNotificationCategories() {
        let okAction = UNNotificationAction(
            identifier: ActionID.ok,
            title: "OK",
            options: []
        )
        
        let startAction = UNNotificationAction(
            identifier: ActionID.startLesson,
            title: "Start Lesson",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: ActionID.remindLater,
            title: "Remind Later",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: CategoryID.dailyReminder,
            actions: [okAction, startAction, remindLaterAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func requestAuthorizationAndScheduleDailyReminder(at hour: Int = 9, minute: Int = 0) {
        requestAuthorization { granted in
            guard granted else { return }
            self.scheduleDailyReminder(at: hour, minute: minute)
        }
    }
    
    func scheduleDailyReminder(at hour: Int = 9, minute: Int = 0) {
        // Ensure categories are registered
        registerNotificationCategories()
        
        // Remove existing daily reminder if any, but don't wipe everything
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyReminder])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to learn! 📚"
        content.body = "Your daily micro-lesson is waiting. Keep that streak going!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = CategoryID.dailyReminder
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0 // Ensure it triggers at the start of the minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.dailyReminder, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder successfully scheduled for \(hour):\(String(format: "%02d", minute))")
                DispatchQueue.main.async {
                    self.checkAuthorization()
                }
            }
        }
    }
    
    func scheduleSmartReminder(basedOn activityHour: Int) {
        // Rule-based: schedule 1 hour after most active learning time
        let reminderHour = (activityHour + 1) % 24
        scheduleDailyReminder(at: reminderHour, minute: 0)
    }
    
    func scheduleContextualReminder(location: String) {
        registerNotificationCategories()
        
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = CategoryID.dailyReminder
        
        switch location {
        case "home":
            content.title = "Relaxing at home? 🏠"
            content.body = "Perfect time for a quick productivity lesson!"
        case "university", "school":
            content.title = "On campus? 🎓"
            content.body = "Take a study break with a tech lesson!"
        case "commute":
            content.title = "Commuting? 🚌"
            content.body = "A 60-second lesson fits perfectly right now!"
        default:
            content.title = "Time to learn! 📚"
            content.body = "Your daily micro-lesson is waiting."
        }
        
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.contextualReminder, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTestInteractiveNotification() {
        registerNotificationCategories()
        
        let content = UNMutableNotificationContent()
        content.title = "MicroSkill Reminder"
        content.body = "This is a test notification. Expand it to see OK, Start Lesson, and Remind Later."
        content.sound = .default
        content.categoryIdentifier = CategoryID.dailyReminder
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.testReminder, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule test notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

