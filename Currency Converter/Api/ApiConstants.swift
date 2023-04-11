//
//  ApiConstants.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import Foundation

class ApiConstants {
    // Split the api urls into common parts so that spelling mistakes do not appear in common parts of api urls
    private static let http = "http"
    private static let https = "https"
    static let openExchangeBaseUrl = "\(https)://openexchangerates.org"
    private static let apiRepo = "api"
    private static let latestRepo = "latest"
    private static let jsonRepo = "json"
    
    // Api Request Types
    static let get = "GET"
    
    // Store authentication tokens in a secure place in the realtime applications
    static let appId = ""
    
    // Api URL for the latest currency update
    static let latestUpdate = "\(openExchangeBaseUrl)/\(apiRepo)/\(latestRepo).\(jsonRepo)"
}
