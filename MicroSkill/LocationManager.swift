import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var detectedContext: String = "unknown"
    @Published var detectedLocationName: String?
    @Published var isTracking = false
    
    @Published var savedLocations: [CustomLocation] = [] {
        didSet {
            saveLocations()
        }
    }
    
    private let manager = CLLocationManager()
    private let geofenceRadius: CLLocationDistance = 150 // Slightly larger for better reliability
    private let groupSuiteName = "group.com.microskill.app"
    
    private var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: groupSuiteName) ?? UserDefaults.standard
    }
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
        loadLocations()
    }
    
    private func loadLocations() {
        if let data = sharedDefaults.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([CustomLocation].self, from: data) {
            self.savedLocations = decoded
        } else {
            // Migrate old Home/University if they exist
            migrateOldLocations()
        }
    }
    
    private func saveLocations() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            sharedDefaults.set(encoded, forKey: "savedLocations")
        }
    }
    
    private func migrateOldLocations() {
        var migrated: [CustomLocation] = []
        
        let oldDefaults = UserDefaults.standard
        if let homeLat = oldDefaults.object(forKey: "homeLatitude") as? Double,
           let homeLon = oldDefaults.object(forKey: "homeLongitude") as? Double {
            migrated.append(CustomLocation(name: "Home", latitude: homeLat, longitude: homeLon, recommendedCategory: "Productivity"))
        }
        
        if let uniLat = oldDefaults.object(forKey: "uniLatitude") as? Double,
           let uniLon = oldDefaults.object(forKey: "uniLongitude") as? Double {
            migrated.append(CustomLocation(name: "University", latitude: uniLat, longitude: uniLon, recommendedCategory: "Tech"))
        }
        
        if !migrated.isEmpty {
            self.savedLocations = migrated
            // Clean up old
            oldDefaults.removeObject(forKey: "homeLatitude")
            oldDefaults.removeObject(forKey: "homeLongitude")
            oldDefaults.removeObject(forKey: "uniLatitude")
            oldDefaults.removeObject(forKey: "uniLongitude")
        }
    }
    
    var canUseLocation: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        guard canUseLocation else { return }
        manager.startUpdatingLocation()
        isTracking = true
    }
    
    func stopTracking() {
        manager.stopUpdatingLocation()
        isTracking = false
    }
    
    func addLocation(name: String, category: String) {
        guard let location = currentLocation else { return }
        let newLocation = CustomLocation(
            name: name,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            recommendedCategory: category
        )
        savedLocations.append(newLocation)
        refreshDetectedContext()
    }
    
    func removeLocation(at offsets: IndexSet) {
        savedLocations.remove(atOffsets: offsets)
        refreshDetectedContext()
    }
    
    private func refreshDetectedContext() {
        let (newContext, name) = detectCurrentContext()
        if newContext != detectedContext || name != detectedLocationName {
            detectedContext = newContext
            detectedLocationName = name
            objectWillChange.send()
        }
    }

    func detectCurrentContext() -> (String, String?) {
        guard let location = currentLocation else { return ("unknown", nil) }
        
        for saved in savedLocations {
            let savedLocation = CLLocation(latitude: saved.latitude, longitude: saved.longitude)
            if location.distance(from: savedLocation) < geofenceRadius {
                return (saved.recommendedCategory.lowercased(), saved.name)
            }
        }
        
        // Check if moving (commute)
        if let speed = manager.location?.speed, speed > 2.5 {
            return ("commute", "Commuting")
        }
        
        return ("unknown", nil)
    }
    
    func recommendedCategory(for context: String) -> String {
        // Now context is directly the category or "commute" or "unknown"
        if context == "commute" {
            return "General Knowledge"
        } else if context == "unknown" {
            return "Tech"
        }
        return context.capitalized
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        refreshDetectedContext()
        
        // Trigger contextual notification if context is known
        if detectedContext != "unknown" {
            NotificationManager.shared.scheduleContextualReminder(location: detectedLocationName ?? detectedContext)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startTracking()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

