//
//  CurrencyCellViewModel.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

protocol CurrencyCellViewModel {

    //is always static
    var currencyCode: String { get }

    // might be fetched from separated endpoint and appear after cell is displayed
    var currencyTitle: SignalProducer<String?, NoError> { get }
    var symbolicIcon: SignalProducer<String?, NoError> { get }

    var amountText: SignalProducer<String?, NoError> { get }
    var userInputObserver: Signal<String?, NoError>.Observer { get }

}

protocol AmountProvider {
    func amount(for currency: String) -> Double?
}

protocol CurrencyCellViewModelDelegate: class {
    func requestMaster(for viewModel: CurrencyCellViewModelImpl, with initialValue: Double)
}

class CurrencyCellViewModelImpl: CurrencyCellViewModel {

    enum Mode {
        case master
        case slave
    }

    weak var delegate: CurrencyCellViewModelDelegate?

    let currencyCode: String
    private var mode: Mode = .slave

    private let currencyTitleProperty = MutableProperty<String?>(nil)
    private let symbolicIconProperty = MutableProperty<String?>(nil)

    private let masterValue = MutableProperty<CalculationBase?>(nil)
    private let updatesPipe = Signal<(), NoError>.pipe()
    private let userInputPipe = Signal<String?, NoError>.pipe()

    private let amountProvider: AmountProvider
    private let currencyInfoProvider: CurrencyInfoProviderWrapper
    private let amountFormatter: NumberFormatter = {
        let fmtr = NumberFormatter()
        fmtr.numberStyle = .decimal
        fmtr.minimumFractionDigits = 2
        fmtr.maximumFractionDigits = 2
        fmtr.decimalSeparator = "."
        fmtr.groupingSeparator = ""
        return fmtr
    }()
    private let dataScheduler: Scheduler = QueueScheduler(qos: .userInitiated)

    init(currencyCode: String, amountProvider: AmountProvider, currencyInfoProvider: CurrencyInfoProviderWrapper) {
        self.currencyCode = currencyCode
        self.amountProvider = amountProvider
        self.currencyInfoProvider = currencyInfoProvider
        subscribeToUserInput()
        getCurrencyInfo()
    }

    var currencyTitle: SignalProducer<String?, NoError> {
        return currencyTitleProperty.producer
    }

    var symbolicIcon: SignalProducer<String?, NoError> {
        return symbolicIconProperty.producer
    }

    var amountText: SignalProducer<String?, NoError> {
        return updatesPipe.output
            .observe(on: dataScheduler)
            .filter { [weak self] in
                self?.mode == .slave
            }
            .map { [weak self] in
                return self?.amountString()
            }
            .observe(on: UIScheduler())
            .producer.prefix(value: amountString())
    }

    var userInputAmount: Signal<String?, NoError>.Observer {
        return userInputPipe.input
    }

    var userInputObserver: Signal<String?, NoError>.Observer {
        return userInputPipe.input
    }

    var updatesObserver: Signal<(), NoError>.Observer {
        return updatesPipe.input
    }

    var userInput: Signal<Double, NoError> {
        return userInputPipe.output.map { [weak self] in
            return $0.flatMap { self?.amountFormatter.number(from: $0)?.doubleValue } ?? 0
        }
    }

    func setMode(_ mode: Mode) {
        dataScheduler.schedule { [weak self] in
            self?.mode = mode
        }
    }

    private func subscribeToUserInput() {
        userInputPipe.output.observe(on: dataScheduler).observeValues { [weak self] input in
            if let `self` = self, self.mode != .master,
                let initialValue = input.flatMap({ self.amountFormatter.number(from: $0)?.doubleValue }) {
                self.delegate?.requestMaster(for: self, with: initialValue)
                self.mode = .master
            }
        }
    }

    private func getCurrencyInfo() {
        currencyInfoProvider.currencyInfo(for: currencyCode) { [weak self] (info) in
            self?.currencyTitleProperty.value = info.name
            self?.symbolicIconProperty.value = info.symbolicIcon
        }
    }

    private func amountString() -> String? {
        guard let amount = amountProvider.amount(for: self.currencyCode) else {
            return nil
        }
        return amountFormatter.string(from: amount as NSNumber)
    }
}
