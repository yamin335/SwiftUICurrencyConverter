//
//  UserSessionManager.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/18/22.
//

import Foundation

class UserSessionManager {
    private static let userDefault = UserDefaults.standard
    
    // Save last update time of currency list
    static var lastUpdateTime: String? {
        set {
            userDefault.set(newValue, forKey: AppConstants.keyLastUpdateTime)
        }
        
        get {
            return userDefault.string(forKey: AppConstants.keyLastUpdateTime)
        }
    }
}
