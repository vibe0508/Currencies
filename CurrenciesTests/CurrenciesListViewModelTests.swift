//
//  CurrenciesListViewModelTests.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import Currencies

class CurrenciesListViewModelTests: XCTestCase {

    var calculatorMock: CalculatorMock!
    var requestorMock: RequestorMock!

    var viewModel: CurrenciesListViewModelImpl!

    override func setUp() {
        super.setUp()

        calculatorMock = CalculatorMock()
        requestorMock = RequestorMock()

        viewModel = CurrenciesListViewModelImpl(calculator: calculatorMock,
                                                requestor: requestorMock)
    }

    func testInitialFetch() {
        let data = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
            ])

        let reloadCalled = expectation(description: UUID().uuidString)
        let cellUpdateCalled = expectation(description: UUID().uuidString)

        viewModel.reloads.take(first: 1).observeValues {
            reloadCalled.fulfill()
        }
        viewModel.valueUpdatesPipe.output.take(first: 1).observeValues {
            cellUpdateCalled.fulfill()
        }

        requestorMock.stateProperty.value = .hasValue(data)

        wait(for: [reloadCalled, cellUpdateCalled], timeout: 1.0)

        XCTAssertEqual(viewModel.cells.count, 4)
        XCTAssertEqual(calculatorMock.dataPassed, data)
    }

    func testRegularFetch() {
        let data1 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
            ])

        let data2 = ExchangeRatesResponse(baseCurrency: "GBP", rates: [
            "EUR": 5,
            "RUB": 3,
            "USD": 3.8
            ])

        requestorMock.stateProperty.value = .hasValue(data1)

        let reloadCalled = expectation(description: UUID().uuidString)
        let cellUpdateCalled = expectation(description: UUID().uuidString)
        reloadCalled.isInverted = true

        viewModel.reloads.take(first: 1).observeValues {
            reloadCalled.fulfill()
        }
        viewModel.valueUpdatesPipe.output.take(first: 1).observeValues {
            cellUpdateCalled.fulfill()
        }

        requestorMock.stateProperty.value = .hasValue(data2)

        wait(for: [reloadCalled, cellUpdateCalled], timeout: 1.0)

        XCTAssertEqual(viewModel.cells.count, 4)
        XCTAssertEqual(calculatorMock.dataPassed, data2)
    }

    func testFetchAddedCurrencies() {
        let data1 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
            ])

        let data2 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "GBP": 5,
            "RUB": 3,
            "USD": 3.8,
            "CHF": 80
            ])

        requestorMock.stateProperty.value = .hasValue(data1)

        let reloadCalled = expectation(description: UUID().uuidString)
        let cellUpdateCalled = expectation(description: UUID().uuidString)

        viewModel.reloads.take(first: 1).observeValues {
            reloadCalled.fulfill()
        }
        viewModel.valueUpdatesPipe.output.take(first: 1).observeValues {
            cellUpdateCalled.fulfill()
        }

        requestorMock.stateProperty.value = .hasValue(data2)

        wait(for: [reloadCalled, cellUpdateCalled], timeout: 1.0)

        XCTAssertEqual(viewModel.cells.count, 5)
        XCTAssertEqual(calculatorMock.dataPassed, data2)
    }

    func testFetchRemovedCurrencies() {
        let data1 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
            ])

        let data2 = ExchangeRatesResponse(baseCurrency: "USD", rates: [
            "GBP": 5,
            "EUR": 3.8
            ])

        requestorMock.stateProperty.value = .hasValue(data1)

        let reloadCalled = expectation(description: UUID().uuidString)
        let cellUpdateCalled = expectation(description: UUID().uuidString)

        viewModel.reloads.take(first: 1).observeValues {
            reloadCalled.fulfill()
        }
        viewModel.valueUpdatesPipe.output.take(first: 1).observeValues {
            cellUpdateCalled.fulfill()
        }

        requestorMock.stateProperty.value = .hasValue(data2)

        wait(for: [reloadCalled, cellUpdateCalled], timeout: 1.0)

        XCTAssertEqual(viewModel.cells.count, 3)
        XCTAssertEqual(calculatorMock.dataPassed, data2)
    }

    func testFetchCurrenciesSwapped() {
        let data1 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
            ])

        let data2 = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "GBP": 5,
            "CHF": 3,
            "USD": 3.8
            ])

        requestorMock.stateProperty.value = .hasValue(data1)

        let reloadCalled = expectation(description: UUID().uuidString)
        let cellUpdateCalled = expectation(description: UUID().uuidString)

        viewModel.reloads.take(first: 1).observeValues {
            reloadCalled.fulfill()
        }
        viewModel.valueUpdatesPipe.output.take(first: 1).observeValues {
            cellUpdateCalled.fulfill()
        }

        requestorMock.stateProperty.value = .hasValue(data2)

        wait(for: [reloadCalled, cellUpdateCalled], timeout: 1.0)

        XCTAssertEqual(viewModel.cells.count, 4)
        XCTAssertEqual(calculatorMock.dataPassed, data2)
    }

    func testAssignMasterVM() {
        let data = ExchangeRatesResponse(baseCurrency: "EUR", rates: [
            "RUB": 2,
            "USD": 3,
            "GBP": 2.8
        ])
        requestorMock.stateProperty.value = .hasValue(data)

        let cell = viewModel.cells[1] as! CurrencyCellViewModelImpl
        let initialValue = 5.9

        viewModel.requestMaster(for: cell, with: initialValue)

        XCTAssertEqual(calculatorMock.basePassed,
                       CalculationBase(currencyCode: cell.currencyCode, amount: initialValue))
        XCTAssertEqual(requestorMock.baseCurrencyPassed, cell.currencyCode)

    }
}
