//
//  Currency_ConverterTests.swift
//  Currency ConverterTests
//
//  Created by Md. Yamin on 9/15/22.
//

import XCTest
@testable import Currency_Converter

class Currency_ConverterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTimeDifferenceInMinutes() throws {
        // This tests the time difference in Minutes between two time values
        
        let previousTimeValue = "20-09-2022 11:31 AM"
        let nextTimeValue = "20-09-2022 12:01 PM"
        
        guard let previousTime = DateUtils.formatStringToDate(value: previousTimeValue), let nextTime = DateUtils.formatStringToDate(value: nextTimeValue) else {
            throw AppError.InvalidTimeDifference
        }
        
        let timeDifferenceInMinutes = try DateUtils.calculateTimeDifferenceInMinutes(from: previousTime, to: nextTime)
        XCTAssertEqual(timeDifferenceInMinutes, 30)
    }
    
    func testConvert_USD_To_BDT() throws {
        // This test checks conversion of USD to another currency e.g. BDT
        let fromCurrency = "USD"
        let toCurrency = "BDT"
        
        let fromCurrencyRate = 1.0
        let toCurrencyRate = 103.0838 // USD to BDT rate
        
        let convertedAmountInUSD = CurrencyConverter.convert(fromCurrency: fromCurrency, toCurrency: toCurrency, fromCurrencyRate: fromCurrencyRate, toCurrencyRate: toCurrencyRate, amount: 4.85042267)
        
        XCTAssertEqual(String(format: "%.4f", convertedAmountInUSD), "500.0000")
    }
    
    func testConvert_BDT_To_USD() throws {
        // This test checks the convertion of BDT to USD
        let fromCurrency = "BDT"
        let toCurrency = "USD"
        
        let fromCurrencyRate = 103.0838 // USD to BDT rate
        let toCurrencyRate = 1.0
        
        let convertedAmountInUSD = CurrencyConverter.convert(fromCurrency: fromCurrency, toCurrency: toCurrency, fromCurrencyRate: fromCurrencyRate, toCurrencyRate: toCurrencyRate, amount: 500)
        
        XCTAssertEqual(String(format: "%.4f", convertedAmountInUSD), "4.8504")
    }
    
    func testConvert_BDT_To_INR_via_USD_Rate() throws {
        // This test checks the convertion of BDT to INR via USD rate
        let fromCurrency = "BDT"
        let toCurrency = "INR"
        
        let fromCurrencyRate = 103.0838 // USD to BDT rate
        let toCurrencyRate = 79.6715 // USD to INR rate
        
        let convertedAmountInUSD = CurrencyConverter.convert(fromCurrency: fromCurrency, toCurrency: toCurrency, fromCurrencyRate: fromCurrencyRate, toCurrencyRate: toCurrencyRate, amount: 500)
        
        XCTAssertEqual(String(format: "%.5f", convertedAmountInUSD), "386.44045")
    }
    
    func testConvert_INR_To_BDT_via_USD_Rate() throws {
        // This test checks the convertion of INR to BDT via USD rate
        let fromCurrency = "INR"
        let toCurrency = "BDT"
        
        let fromCurrencyRate = 79.6715 // USD to INR rate
        let toCurrencyRate = 103.0838 // USD to BDT rate
        
        let convertedAmountInUSD = CurrencyConverter.convert(fromCurrency: fromCurrency, toCurrency: toCurrency, fromCurrencyRate: fromCurrencyRate, toCurrencyRate: toCurrencyRate, amount: 386.44045)
        
        XCTAssertEqual(String(format: "%.5f", convertedAmountInUSD), "500.00000")
    }
    
    func testTheValidityOfCurrencyAmount() {
        // This test checks validity of user input as a valid number
        XCTAssertEqual(CurrencyConverter.isValid(amount: ".1"), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "1."), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: ".1."), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: ".1.."), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "..1."), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "0.1"), true)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "1"), true)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "@1"), false)
        XCTAssertEqual(CurrencyConverter.isValid(amount: "abc1"), false)
    }

}
