//
//  Dictionary+Decodable.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

private struct JSONCodingKey: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
    }

    var intValue: Int? {
        return Int(stringValue)
    }
}

extension Dictionary: Decodable where Key == String, Value: Equatable {
    
}


