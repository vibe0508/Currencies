//
//  AmountCalculator.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

protocol AmountCalculatorWrapper: AmountProvider {
    func set(_ base: CalculationBase)
    func set(_ data: ExchangeRatesResponse)
}

class AmountCalculator {

    private let queue = DispatchQueue(label: "AmountCalculator", qos: .userInitiated, attributes: [.concurrent])

    private var data: ExchangeRatesResponse?
    private var base: CalculationBase
    private lazy var preconvertedBase: CalculationBase = self.queue.sync(execute: calcPreconvertedBase)

    init(base: CalculationBase) {
        self.base = base
    }

    private func calcPreconvertedBase() -> CalculationBase {
        guard let data = data,
            let rate = data.rates[base.currencyCode],
            data.baseCurrency != base.currencyCode else {
            return base
        }
        return CalculationBase(currencyCode: data.baseCurrency,
                               amount: base.amount != 0 ? rate / base.amount : 0)
    }

}

extension AmountCalculator: AmountCalculatorWrapper {

    func set(_ data: ExchangeRatesResponse) {
        queue.async(flags: .barrier) { [unowned self] in
            let `self` = self
            self.data = data
            self.preconvertedBase = self.calcPreconvertedBase()
        }
    }

    func set(_ base: CalculationBase) {
        queue.async(flags: .barrier) { [unowned self] in
            let `self` = self
            self.base = base
            self.preconvertedBase = self.calcPreconvertedBase()
        }
    }

    func amount(for currency: String) -> Double? {
        return queue.sync {
            guard currency != base.currencyCode else {
                return base.amount
            }
            return data?.rates[currency].flatMap { preconvertedBase.amount * $0 }
        }
    }
}
