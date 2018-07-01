//
//  Configuration.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct Configuration {

    static var isTestEnvironment: Bool {
        return NSClassFromString("XCTestCase") != nil
    }

    struct Policy {
        static var maxCacheLifetime: TimeInterval {
            return Configuration.isTestEnvironment ? 3 : 600
        }
        static let refreshRate: TimeInterval = 1
        static let startupBase = CalculationBase(currencyCode: "EUR", amount: 1)
    }

    struct Networking {
        static let baseUrl = "https://revolut.duckdns.org/"
        struct Endpoints {
            static let currency = "latest"
        }
    }
}

extension URLRequest {
    static func currencies(with base: String) -> URLRequest {
        let baseUrl = Configuration.Networking.baseUrl
        let endpoint = Configuration.Networking.Endpoints.currency
        let url = "\(baseUrl)\(endpoint)?base=\(base)"
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = Configuration.Policy.refreshRate
        return request
    }
}
