//
//  NetworkMock.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
@testable import Currencies

class NetworkMock<MockData: Decodable>: NetworkWrapper {

    enum Result {
        case success(MockData)
        case failure(Error)
    }

    var request: URLRequest?
    var queue: DispatchQueue?

    var expectedResult: Result?

    func perform<T: Decodable>(_ request: URLRequest, responseOn queue: DispatchQueue, completion: @escaping (T) -> (), failure: @escaping (Error) -> ()) {
        guard T.self == MockData.self else {
            fatalError()
        }
        self.request = request
        self.queue = queue

        guard let expectedResult = expectedResult else {
            return
        }

        switch expectedResult {
        case .success(let data):
            completion(data as! T)
        case .failure(let error):
            failure(error)
        }
    }

    func reset() {
        self.request = nil
        self.queue = nil
        self.expectedResult = nil
    }
}
