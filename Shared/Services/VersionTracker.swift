//
//  PersistentVersioning.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/25/25.
//

import Foundation

struct VersionTracker {
    static var appVersion: Int = 1
    static var appVersionKey: String = "app-version"
    
    static func shouldStoreAppVersion() -> Bool {
        return UserDefaults.standard.object(forKey: appVersionKey) == nil
    }
    
    static func storeAppVersion() {
        // Verify that there is no stored app version yet
        assert(shouldStoreAppVersion(),
               "Attempted to store app version when one already exists.")
        devPrint("Storing app version...")
        let defaults = UserDefaults.standard
        defaults.set(appVersion, forKey: appVersionKey)
    }
    
    static func inbuiltAppVersionString() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(version) (\(build))"
    }
    
    static func printInbuiltAppVersion() {
        print(inbuiltAppVersionString())
    }
}
