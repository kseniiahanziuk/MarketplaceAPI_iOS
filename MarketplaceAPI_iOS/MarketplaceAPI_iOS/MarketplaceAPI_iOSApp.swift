import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        setupAnalytics()
        setupCrashlytics()
        
        return true
    }
    
    private func setupAnalytics() {
        Analytics.setAnalyticsCollectionEnabled(true)
        
        Analytics.setDefaultEventParameters([
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "platform": "iOS"
        ])
    }
    
    private func setupCrashlytics() {
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        Crashlytics.crashlytics().setCustomValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown", forKey: "app_version")
        Crashlytics.crashlytics().setCustomValue("iOS", forKey: "platform")
    }
    
    func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CrashlyticsManager.shared.recordError(error, userInfo: ["context": "push_notification_registration"])
    }
}

@main
struct MarketplaceAPI_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var productFilter = ProductFilter()
    
    var body: some Scene {
        WindowGroup {
            ContentView(productFilter: $productFilter)
                .onAppear {
                    AnalyticsManager.shared.logAppLaunch()
                    
                    setupUserTracking()
                }
        }
    }
    
    private func setupUserTracking() {
        let customerId = getOrCreateCustomerId()
        
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail"),
           let userName = UserDefaults.standard.string(forKey: "userName") {
            
            Analytics.setUserProperty(userEmail, forName: "user_email")
            Analytics.setUserProperty(userName, forName: "user_name")
            Analytics.setUserProperty(customerId, forName: "customer_id")
            
            CrashlyticsManager.shared.setUserEmail(userEmail)
            CrashlyticsManager.shared.setUserName(userName)
            CrashlyticsManager.shared.setUserID(customerId)
            CrashlyticsManager.shared.setCustomKey("customer_id", value: customerId)
        } else {
            Analytics.setUserProperty(customerId, forName: "customer_id")
            CrashlyticsManager.shared.setUserID(customerId)
            CrashlyticsManager.shared.setCustomKey("customer_id", value: customerId)
        }
        
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        Analytics.setUserProperty(deviceModel, forName: "device_model")
        Analytics.setUserProperty(systemVersion, forName: "ios_version")
        
        CrashlyticsManager.shared.setCustomKey("device_model", value: deviceModel)
        CrashlyticsManager.shared.setCustomKey("ios_version", value: systemVersion)
    }
    
    private func getOrCreateCustomerId() -> String {
        if let existingCustomerId = UserDefaults.standard.string(forKey: "customerId"),
           !existingCustomerId.isEmpty {
            return existingCustomerId
        } else {
            let newCustomerId = UUID().uuidString
            UserDefaults.standard.set(newCustomerId, forKey: "customerId")
            return newCustomerId
        }
    }
}
