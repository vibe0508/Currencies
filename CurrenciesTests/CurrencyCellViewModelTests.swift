//
//  CurrencyCellViewModelTests.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import XCTest
@testable import Currencies

class CurrencyCellViewModelTests: XCTestCase {
    var calculatorMock: CalculatorMock!
    var delegateMock: CurrencyCellVMDelegateMock!

    var viewModel: CurrencyCellViewModelImpl!

    override func setUp() {
        super.setUp()

        calculatorMock = CalculatorMock()
        delegateMock = CurrencyCellVMDelegateMock()

        viewModel = CurrencyCellViewModelImpl(currencyCode: "CHF", amountProvider: calculatorMock)
        viewModel.delegate = delegateMock
    }

    func testUpdateWhenSlave() {
        viewModel.setMode(.slave)

        let amount = 10.0
        calculatorMock.amountToReturn = amount

        let textUpdated = expectation(description: UUID().uuidString)
        viewModel.amountText.take(first: 1).startWithValues {
            XCTAssertEqual($0, "10")
            textUpdated.fulfill()
        }

        viewModel.updatesObserver.send(value: ())

        wait(for: [textUpdated], timeout: 1.0)

        XCTAssertEqual(calculatorMock.currencyPassed, "CHF")
    }

    func testUpdateWhenMaster() {
        viewModel.setMode(.master)

        let textUpdated = expectation(description: UUID().uuidString)
        textUpdated.isInverted = true
        viewModel.amountText.take(first: 1).startWithValues { _ in
            textUpdated.fulfill()
        }

        viewModel.updatesObserver.send(value: ())

        wait(for: [textUpdated], timeout: 1.0)
    }
}
