//
//  Extensions.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/16/22.
//

import Foundation
import SwiftUI

extension Double {
    // Rounds a double value to provided decimal places
    func round(toPlaces digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

extension View {
    // Hides phone keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension AppError {
    var isFatal: Bool {
        if case AppError.Unexpected = self { return true }
        else { return false }
    }
}

// For each error type return the appropriate description
extension AppError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .InvalidServerResponse:
            return "Server retuned an invalid response!"
        case .InvalidTimeDifference:
            return "One of the provided times is invalid!"
        case .Unexpected(let errorCode):
            return "An unexpected error occurred with code: \(errorCode)!"
        }
    }
}

// For each error type return the appropriate localized description
extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .InvalidServerResponse:
            return NSLocalizedString(
                "Server response is not valid.",
                comment: "Invalid Response"
            )
        case .InvalidTimeDifference:
            return NSLocalizedString(
                "The specified times are not valid.",
                comment: "Invalid Time"
            )
        case .Unexpected(let errorCode):
            return NSLocalizedString(
                "An unexpected error occurred with code: \(errorCode)!",
                comment: "Unexpected Error"
            )
        }
    }
}
