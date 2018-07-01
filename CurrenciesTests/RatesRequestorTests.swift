//
//  RatesRequestorTests.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import XCTest
import Reachability
@testable import Currencies

private let hasValueFilter: (RatesRequestor.State) -> Bool = {
    if case .hasValue = $0 {
        return true
    }
    return false
}

private let errorFilter: (RatesRequestor.State) -> Bool = {
    if case .error = $0 {
        return true
    }
    return false
}

class RatesRequestorTests: XCTestCase {

    var requestor: RatesRequestor!
    var network: NetworkMock<ExchangeRatesResponse>!
    var reachability: ReachabilityMock!

    override func setUp() {
        network = NetworkMock<ExchangeRatesResponse>()
        reachability = ReachabilityMock()

        requestor = RatesRequestor(network: network, reachability: reachability)
    }

    func testNormalSchedule() {
        let desiredNumber = 3

        network.expectedResult = .success(ExchangeRatesResponse(baseCurrency: "EUR", rates: []))

        let desiredRefreshHappened = expectation(description: UUID().uuidString)

        requestor.start()

        requestor.state
            .skip(first: desiredNumber)
            .filter(hasValueFilter)
            .take(first: 1)
            .startWithValues { _ in
                desiredRefreshHappened.fulfill()
            }

        wait(for: [desiredRefreshHappened],
             timeout: Double(desiredNumber) * Configuration.Policy.refreshRate * 1.25)

    }

    func testBaseChange() {

        network.expectedResult = .success(ExchangeRatesResponse(baseCurrency: "EUR", rates: []))

        let desiredRefreshHappened = expectation(description: UUID().uuidString)

        requestor.set("RUB")
        requestor.start()

        requestor.state.skip(first: 1).take(first: 1).startWithValues { [weak requestor, network] _ in
            XCTAssertEqual(network?.request?.url?.query, "base=RUB")
            requestor?.set("USD")
        }

        requestor.state.skip(first: 2).take(first: 1).startWithValues { [network] _ in
            XCTAssertEqual(network?.request?.url?.query, "base=USD")
            desiredRefreshHappened.fulfill()
        }

        wait(for: [desiredRefreshHappened],
             timeout: Configuration.Policy.refreshRate * 2.25)

    }

    func testNoConnection() {
        network.expectedResult = .failure(URLError(.notConnectedToInternet))

        requestor.start()
        sleep(1)

        XCTAssertNotNil(reachability.whenReachable)

        network.expectedResult = .success(ExchangeRatesResponse(baseCurrency: "EUR", rates: []))
        reachability.whenReachable?(Reachability()!)

        let desiredRefreshHappened = expectation(description: UUID().uuidString)
        requestor.state.skip(first: 1).take(first: 1).startWithValues { state in
            guard case .hasValue = state else {
                return
            }
            desiredRefreshHappened.fulfill()
        }

        wait(for: [desiredRefreshHappened], timeout: 2.0)

    }

    func testNoConnectionCacheInvalidated() {

        let cacheInvalidated = expectation(description: UUID().uuidString)
        let desiredRefreshHappened = expectation(description: UUID().uuidString)
        network.expectedResult = .success(ExchangeRatesResponse(baseCurrency: "EUR", rates: []))
        requestor.start()

        requestor.state.filter(hasValueFilter).take(first: 1).startWithValues { [network] _ in
            network?.expectedResult = .failure(URLError(.notConnectedToInternet))
        }
        requestor.state.filter(hasValueFilter).skip(first: 1).take(first: 1).startWithValues { _ in
            desiredRefreshHappened.fulfill()
        }
        requestor.state.filter(errorFilter).take(first: 1).startWithValues { _ in
            cacheInvalidated.fulfill()
        }

        wait(for: [cacheInvalidated], timeout: Configuration.Policy.maxCacheLifetime * 1.2)

        XCTAssertNotNil(reachability.whenReachable)

        network.expectedResult = .success(ExchangeRatesResponse(baseCurrency: "EUR", rates: []))
        reachability.whenReachable?(Reachability()!)

        wait(for: [desiredRefreshHappened], timeout: 2.0)

    }

}
