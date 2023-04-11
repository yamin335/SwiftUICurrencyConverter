//
//  CurrencyUpdateResponse.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import Foundation

struct CurrencyUpdateResponse: Codable {
    let disclaimer: String?
    let license: String?
    let timestamp: Int?
    let base: String?
    let rates: [String: Double]?
}

struct CurrencyData {
    let code: String
    let amount: String
}
