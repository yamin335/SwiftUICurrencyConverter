//
//  AppError.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/18/22.
//

import Foundation

// Custom error class
enum AppError: Error {
    // Throw when an invalid server response is found
    case InvalidServerResponse

    // Throw when a time difference calculation gives nil value
    case InvalidTimeDifference

    // Throw in all other cases
    case Unexpected(code: Int)
}
