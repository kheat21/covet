//
//  LocalSettingsService.swift
//  Covet
//
//  Created by Covet on 2/2/22.
//

import Foundation
import Combine

class LocalSettingsService: NSObject, ObservableObject {
    
    static let SHOW_NOTIFICATION_WHEN_REFRESHING_USER_KEY = "SHOW_NOTIFICATION_WHEN_REFRESHING_USER_KEY"
    static let SHOW_ERROR_WHEN_USER_REFRESH_FAILS = "SHOW_ERROR_WHEN_USER_REFRESH_FAILS"
    
    @Published var showNotificationWhenRefreshingUser: Bool = getDefaultBoolValue(
        key: LocalSettingsService.SHOW_NOTIFICATION_WHEN_REFRESHING_USER_KEY, defaultValue: false
    );
    func setShowNotificationWhenRefreshingUser(val: Bool) {
        setBoolValue(key: LocalSettingsService.SHOW_NOTIFICATION_WHEN_REFRESHING_USER_KEY, val: val)
    }
    
    @Published var showErrorWhenUserRefreshFails: Bool = getDefaultBoolValue(
        key: LocalSettingsService.SHOW_ERROR_WHEN_USER_REFRESH_FAILS, defaultValue: false
    );
    func setShowErrorWhenUserRefreshFails(val: Bool) {
        setBoolValue(key: LocalSettingsService.SHOW_ERROR_WHEN_USER_REFRESH_FAILS, val: val)
    }
    
        
}

func getDefaultBoolValue(key: String, defaultValue: Bool) -> Bool {
    if Defaults.sharedSuite.value(forKey: key) != nil {
        return Defaults.sharedSuite.bool(forKey: key)
    }
    return defaultValue
}

func setBoolValue(key: String, val: Bool) {
    Defaults.sharedSuite.set(val, forKey: key)
}
