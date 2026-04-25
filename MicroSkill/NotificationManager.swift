import UserNotifications
import Foundation
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorization()
        registerNotificationCategories()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("Notification auth error: \(error)")
                }
            }
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerNotificationCategories() {
        let startAction = UNNotificationAction(
            identifier: "START_LESSON",
            title: "Start Lesson",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Later",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "DAILY_REMINDER",
            actions: [startAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func scheduleDailyReminder(at hour: Int = 9, minute: Int = 0) {
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to learn! 📚"
        content.body = "Your daily micro-lesson is waiting. Keep that streak going!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "DAILY_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func scheduleSmartReminder(basedOn activityHour: Int) {
        // Rule-based: schedule 1 hour after most active learning time
        let reminderHour = (activityHour + 1) % 24
        scheduleDailyReminder(at: reminderHour, minute: 0)
    }
    
    func scheduleContextualReminder(location: String) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "DAILY_REMINDER"
        
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
        let request = UNNotificationRequest(identifier: "contextual-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}


