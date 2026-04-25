import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var detectedContext: String = "unknown"
    @Published var isTracking = false
    
    private let manager = CLLocationManager()
    private let geofenceRadius: CLLocationDistance = 100
    
    private var homeCoordinate: CLLocationCoordinate2D? {
        get {
            guard let lat = UserDefaults.standard.object(forKey: "homeLatitude") as? Double,
                  let lon = UserDefaults.standard.object(forKey: "homeLongitude") as? Double else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        set {
            UserDefaults.standard.set(newValue?.latitude, forKey: "homeLatitude")
            UserDefaults.standard.set(newValue?.longitude, forKey: "homeLongitude")
        }
    }
    
    private var universityCoordinate: CLLocationCoordinate2D? {
        get {
            guard let lat = UserDefaults.standard.object(forKey: "uniLatitude") as? Double,
                  let lon = UserDefaults.standard.object(forKey: "uniLongitude") as? Double else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        set {
            UserDefaults.standard.set(newValue?.latitude, forKey: "uniLatitude")
            UserDefaults.standard.set(newValue?.longitude, forKey: "uniLongitude")
        }
    }
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
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
    
    func setHomeLocation() {
        guard let location = currentLocation else { return }
        homeCoordinate = location.coordinate
    }
    
    func setUniversityLocation() {
        guard let location = currentLocation else { return }
        universityCoordinate = location.coordinate
    }
    
    func detectContext() -> String {
        guard let location = currentLocation else { return "unknown" }
        
        // Check if at home
        if let home = homeCoordinate {
            let homeLocation = CLLocation(latitude: home.latitude, longitude: home.longitude)
            if location.distance(from: homeLocation) < geofenceRadius {
                return "home"
            }
        }
        
        // Check if at university
        if let uni = universityCoordinate {
            let uniLocation = CLLocation(latitude: uni.latitude, longitude: uni.longitude)
            if location.distance(from: uniLocation) < geofenceRadius {
                return "university"
            }
        }
        
        // Check if moving (commute)
        if let speed = manager.location?.speed, speed > 2.0 {
            return "commute"
        }
        
        return "unknown"
    }
    
    func recommendedCategory(for context: String) -> String {
        switch context {
        case "home":
            return "Productivity"
        case "university", "school":
            return "Tech"
        case "commute":
            return "General Knowledge"
        default:
            return "Tech"
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        let newContext = detectContext()
        if newContext != detectedContext {
            detectedContext = newContext
            // Trigger contextual notification if context changed to a known place
            if newContext != "unknown" {
                NotificationManager.shared.scheduleContextualReminder(location: newContext)
            }
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

