//
//  ReachabilityMock.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Reachability
@testable import Currencies

class ReachabilityMock: ReachabilityWrapper {
    var whenReachable: Reachability.NetworkReachable?
}
