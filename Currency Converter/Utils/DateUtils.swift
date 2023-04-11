//
//  DateUtils.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/18/22.
//

import Foundation

class DateUtils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        return formatter
    }()
    // Calculate time difference in Minutes between two provided times
    static func calculateTimeDifferenceInMinutes(from previousTime: Date, to nextTime: Date) throws -> Int {
        guard let difference = Calendar.current.dateComponents([.minute], from: previousTime, to: nextTime).minute else {
            throw AppError.InvalidTimeDifference
        }
        
        return difference
    }
    
    static func formatDateToString(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func formatStringToDate(value: String) -> Date? {
        return dateFormatter.date(from: value)
    }
}
