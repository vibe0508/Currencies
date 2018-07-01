//
//  CalculatorTests.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import XCTest
@testable import Currencies

class CalculatorTests: XCTestCase {
    var calculator: AmountCalculator!

    override func setUp() {
        super.setUp()
        calculator = AmountCalculator(base: .mocked)
    }

    func testCalculationWithoutData() {
        XCTAssertEqual(calculator.amount(for: CalculationBase.mocked.currencyCode),
                       CalculationBase.mocked.amount)
        XCTAssertNil(calculator.amount(for: "XXX"))
    }

    func testCalculationWithData() {
        let data = ExchangeRatesResponse(baseCurrency: CalculationBase.mocked.currencyCode,
                                         rates: ["USD": 2])
        calculator.set(data)

        XCTAssertEqual(calculator.amount(for: "USD"),
                       CalculationBase.mocked.amount * 2)
        XCTAssertEqual(calculator.amount(for: CalculationBase.mocked.currencyCode),
                       CalculationBase.mocked.amount)
        XCTAssertNil(calculator.amount(for: "AUD"))
    }

    func testBaseCurrencyDoesntMatchBaseCalc() {
        let data = ExchangeRatesResponse(baseCurrency: "CHF",
                                         rates: ["JPY": 2,
                                                 "USD": 4])
        let base = CalculationBase(currencyCode: "JPY", amount: 40)
        calculator.set(base)
        calculator.set(data)

        XCTAssertEqual(calculator.amount(for: "USD"), 80)
        XCTAssertEqual(calculator.amount(for: "JPY"), 40)
        XCTAssertEqual(calculator.amount(for: "CHF"), 20)
        XCTAssertNil(calculator.amount(for: "AUD"))
    }

    func testDataSwitch() {
        let data1 = ExchangeRatesResponse(baseCurrency: "CHF",
                                         rates: ["JPY": 2,
                                                 "USD": 4])
        let data2 = ExchangeRatesResponse(baseCurrency: "CHF",
                                          rates: ["JPY": 2])
        let base = CalculationBase(currencyCode: "JPY", amount: 40)
        calculator.set(base)
        calculator.set(data1)

        XCTAssertNotNil(calculator.amount(for: "USD"))

        calculator.set(data2)

        XCTAssertNil(calculator.amount(for: "USD"))
    }

    func testBaseSwitch() {
        let data = ExchangeRatesResponse(baseCurrency: "CHF",
                                         rates: ["JPY": 2,
                                                 "USD": 4])

        let base1 = CalculationBase(currencyCode: "JPY", amount: 40)
        let base2 = CalculationBase(currencyCode: "USD", amount: 33)
        calculator.set(base1)
        calculator.set(data)

        XCTAssertEqual(calculator.amount(for: "JPY"), 40)
        XCTAssertEqual(calculator.amount(for: "USD"), 80)

        calculator.set(base2)

        XCTAssertEqual(calculator.amount(for: "JPY"), 16.5)
        XCTAssertEqual(calculator.amount(for: "USD"), 33)
    }
}
