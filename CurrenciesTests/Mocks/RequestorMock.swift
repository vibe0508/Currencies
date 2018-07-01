//
//  RequestorMock.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
@testable import Currencies

class RequestorMock: RatesRequestorWrapper {

    let stateProperty = MutableProperty(RatesRequestor.State.noValue)

    var state: SignalProducer<RatesRequestor.State, NoError> {
        return stateProperty.producer
    }

    private(set) var isStartCalled = false
    private(set) var isStopCalled = false
    private(set) var baseCurrencyPassed: String?

    func set(_ baseCurrency: String) {
        baseCurrencyPassed = baseCurrency
    }

    func start() {
        isStartCalled = true
    }

    func stop() {
        isStopCalled = true
    }

}
