//
//  CurrencyCellVMDelegateMock.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
@testable import Currencies

class CurrencyCellVMDelegateMock: CurrencyCellViewModelDelegate {
    var initialValuePassed: Double?

    func requestMaster(for viewModel: CurrencyCellViewModelImpl, with initialValue: Double) {
        initialValuePassed = initialValue
    }
}
