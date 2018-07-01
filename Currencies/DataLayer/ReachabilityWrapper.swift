//
//  ReachabilityWrapper.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Reachability

protocol ReachabilityWrapper: class {
    var whenReachable: Reachability.NetworkReachable? { get set }
}

extension Reachability: ReachabilityWrapper {
}
