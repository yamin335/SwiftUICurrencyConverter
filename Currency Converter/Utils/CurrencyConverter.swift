//
//  CurrencyConverter.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/18/22.
//

import Foundation

class CurrencyConverter {
    // Converts a currency to other expected currency
    static func convert(fromCurrency: String, toCurrency: String, fromCurrencyRate: Double, toCurrencyRate: Double, amount: Double) -> Double {
        var convertedAmount = 0.0
        
        if fromCurrency == AppConstants.usDollar {
            convertedAmount = amount * toCurrencyRate
        } else if toCurrency == AppConstants.usDollar {
            convertedAmount = amount / fromCurrencyRate
        } else {
            let usdAmount = amount / fromCurrencyRate
            convertedAmount = toCurrencyRate * usdAmount
        }
        
        return convertedAmount
    }
    
    static func isValid(amount: String) -> Bool {
        let regexPattern = #"^[0-9]+(?:[.,][0-9]+)*$"#
        let range = amount.range(of: regexPattern, options: .regularExpression)
        if range != nil {
            return true
        } else {
            return false
        }
    }
}
