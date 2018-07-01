//
//  NetworkWrapper.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Alamofire

//let's wrap network layer in order to mock it easily
protocol NetworkWrapper {
    func perform<T: Decodable>(_ request: URLRequest,
                               responseOn queue: DispatchQueue,
                               completion: @escaping (T) -> (),
                               failure: @escaping (Error) -> ())
}

class AlamofireWrapper: NetworkWrapper {
    func perform<T>(_ request: URLRequest, responseOn queue: DispatchQueue, completion: @escaping (T) -> (), failure: @escaping (Error) -> ()) where T : Decodable {
        Alamofire.request(request).responseData(queue: queue) { [decoder] (response) in
            switch response.result {
            case .success(let data):
                do {
                    completion(try decoder.decode(T.self, from: data))
                } catch {
                    failure(error)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }

    private let decoder = JSONDecoder()
    func perform<T: Decodable>(_ request: URLRequest, completion: @escaping (T) -> (), failure: @escaping (Error) -> ()) {

    }
}
