import Foundation
import FirebaseCrashlytics

class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    
    private init() {}
    
    func setUserID(_ userID: String) {
        Crashlytics.crashlytics().setUserID(userID)
        log("User ID set: \(userID)")
    }
    
    func setUserEmail(_ email: String) {
        Crashlytics.crashlytics().setCustomValue(email, forKey: "email")
        log("User email set")
    }
    
    func setUserName(_ name: String) {
        Crashlytics.crashlytics().setCustomValue(name, forKey: "name")
        log("User name set")
    }
    
    func setCustomKey(_ key: String, value: Any) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func log(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        Crashlytics.crashlytics().log("[\(timestamp)] \(message)")
    }
    
    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        var enhancedUserInfo = userInfo ?? [:]
        enhancedUserInfo["timestamp"] = Date().timeIntervalSince1970
        enhancedUserInfo["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        Crashlytics.crashlytics().record(error: error, userInfo: enhancedUserInfo)
        log("Error recorded: \(error.localizedDescription)")
    }
    
    func recordNonFatalError(_ domain: String, code: Int, userInfo: [String: Any]? = nil) {
        let error = NSError(domain: domain, code: code, userInfo: userInfo)
        recordError(error)
    }
    
    func testCrash() {
        #if DEBUG
        log("Test crash triggered")
        fatalError("Test crash for changing content view")
        #endif
    }
}
