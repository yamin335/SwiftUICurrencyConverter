//
//  CurrencyConverterViewModel.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import Foundation
import Combine
import SwiftUI
import CoreData

class CurrencyConverterViewModel: BaseViewModel {
    @Published var amount: String = "1"
    
    private var latestCurrencyUpdateSubscriber: AnyCancellable? = nil
    private var validNumberInputChecker: AnyCancellable!
    var latestCurrencyUpdateListPublisher = PassthroughSubject<[String : Double], Never>()
    var shouldRefreshData = PassthroughSubject<Bool, Never>()
    
    var currencyDataDict: [String : Double] = [:]
    
    private var timer: Timer? = nil
    var selectedCurrency = AppConstants.usDollar
    
    override init() {
        super.init()
        validNumberInputChecker = $amount.sink { value in
            let regexPattern = #"[.]{2}"#
            let range = value.range(of: regexPattern, options: .regularExpression)
            //Check and correct if the new string contains any invalid number
            if value.starts(with: ".") {
                
                //clean the string (do this on the main thread to avoid overlapping with the current ContentView update cycle)
                DispatchQueue.main.async {
                    self.amount = "0\(value)"
                }
            } else if range != nil {
                // Replace consecutive multiple dot(.) like (....) with a dot(.)
                DispatchQueue.main.async {
                    var temp: String = value
                    temp.replaceSubrange(range!, with: ["."])
                    self.amount = temp
                }
            } else if value.count > AppConstants.maxAllowedDigit {
                // Restrict all input number of length greater than 7 digit
                DispatchQueue.main.async {
                    var temp: String = value
                    let range = temp.index(temp.startIndex, offsetBy: AppConstants.maxAllowedDigit)..<temp.endIndex
                    temp.removeSubrange(range)
                    self.amount = temp
                }
            }
        }
    }
    
    deinit {
        latestCurrencyUpdateSubscriber?.cancel()
        validNumberInputChecker?.cancel()
        timer?.invalidate()
        timer = nil
    }
    
    func startCurrencyUpdate() {
        let lastUpdateTime = UserSessionManager.lastUpdateTime
        if lastUpdateTime == nil {
            UserSessionManager.lastUpdateTime = DateUtils.formatDateToString(date: Date())
            getLatestCurrencyUpdate()
        } else if shouldUpdateCurrencyNow() {
            getLatestCurrencyUpdate()
        }
        
        scheduleCurrencyUpdateTimer()
    }
    
    private func shouldUpdateCurrencyNow() -> Bool {
        var shouldUpdate = false
        do {
            guard let lastUpdateTime = UserSessionManager.lastUpdateTime,
                  let fromDate = DateUtils.formatStringToDate(value: lastUpdateTime) else {
                throw AppError.InvalidTimeDifference
            }
            
            let timeDifferenceInMinute = try DateUtils.calculateTimeDifferenceInMinutes(from: fromDate, to: Date())
            
            shouldUpdate = timeDifferenceInMinute >= AppConstants.currencyRefreshThresholdTime
        } catch AppError.InvalidTimeDifference {
            print(AppError.InvalidTimeDifference.localizedDescription)
        } catch {
            print(error.localizedDescription)
        }
        
        return shouldUpdate
    }
    
    private func scheduleCurrencyUpdateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            if self.shouldUpdateCurrencyNow() {
                self.getLatestCurrencyUpdate()
            }
        })
    }
    
    func getLatestCurrencyUpdate() {
        self.latestCurrencyUpdateSubscriber = ApiService.shared.latestCurrencyUpdate(viewModel: self)?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                }
            }, receiveValue: { apiResponse in
                if let rates = apiResponse.rates, !rates.isEmpty {
                    UserSessionManager.lastUpdateTime = DateUtils.formatDateToString(date: Date())
                    self.latestCurrencyUpdateListPublisher.send(rates)
                    self.successToastPublisher.send((true, "Currency data updated successfully!"))
                    print("Currency last updated at: \(UserSessionManager.lastUpdateTime ?? "Undefined Time")")
                }
            })
    }
}
