//
//  CurrenciesListViewModel.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Result
import ReactiveSwift

protocol CurrenciesListViewModel {
    var reloads: Signal<(), NoError> { get }
    var cells: [CurrencyCellViewModel] { get }
}

class CurrenciesListViewModelImpl: CurrenciesListViewModel {

    typealias Calculator = AmountCalculatorWrapper & AmountProvider

    private var cellViewModels: [CurrencyCellViewModelImpl] = []

    private let reloadsPipe = Signal<(), NoError>.pipe()
    let valueUpdatesPipe = Signal<(), NoError>.pipe()

    private var masterSubscription: Disposable?
    private weak var currentMasterCellViewModel: CurrencyCellViewModelImpl?

    private let calculator: Calculator
    private let requestor: RatesRequestorWrapper

    convenience init() {
        self.init(calculator: AmountCalculator(base: Configuration.Policy.startupBase),
                  requestor: RatesRequestor())
    }

    init(calculator: Calculator, requestor: RatesRequestorWrapper) {
        self.calculator = calculator
        self.requestor = requestor
        setupSubscriptions()
        self.requestor.start()
    }

    var reloads: Signal<(), NoError> {
        return reloadsPipe.output.observe(on: UIScheduler())
    }

    var cells: [CurrencyCellViewModel] {
        return cellViewModels as [CurrencyCellViewModel]
    }

    private func setupSubscriptions() {
        requestor.state.startWithValues { [weak self] in
            switch $0 {
            case .hasValue(let newData):
                self?.process(newData)
            default:
                self?.cellViewModels = []
                self?.reloadsPipe.input.send(value: ())
            }
        }
    }

    private func cellViewModel(for currencyCode: String) -> CurrencyCellViewModelImpl {
        let viewModel = CurrencyCellViewModelImpl(currencyCode: currencyCode,
                                                  amountProvider: calculator)
        valueUpdatesPipe.output.observe(viewModel.updatesObserver)
        viewModel.delegate = self
        return viewModel
    }

    private func process(_ newData: ExchangeRatesResponse) {

        calculator.set(newData)
        valueUpdatesPipe.input.send(value: ())

        let newCurrencies = Set(newData.rates.map { $0.key } + [newData.baseCurrency])
        let existingCurrencies = Set(cellViewModels.map { $0.currencyCode })

        guard newCurrencies != existingCurrencies else {
            return
        }

        newCurrencies.subtracting(existingCurrencies).forEach {
            cellViewModels.append(cellViewModel(for: $0))
        }

        existingCurrencies.subtracting(newCurrencies).forEach { currency in
            guard let index = cellViewModels.index(where: { $0.currencyCode == currency }) else {
                return
            }
            _ = cellViewModels.remove(at: index)
        }

        reloadsPipe.input.send(value: ())
    }
}

extension CurrenciesListViewModelImpl: CurrencyCellViewModelDelegate {
    func requestMaster(for viewModel: CurrencyCellViewModelImpl, with initialValue: Double) {
        masterSubscription?.dispose()
        currentMasterCellViewModel?.setMode(.slave)

        calculator.set(CalculationBase(currencyCode: viewModel.currencyCode,
                                       amount: initialValue))
        requestor.set(viewModel.currencyCode)
        currentMasterCellViewModel = viewModel

        masterSubscription = viewModel.userInput.observeValues { [
            currencyCode = viewModel.currencyCode,
            calculator,
            pipe = valueUpdatesPipe] amount in

            calculator.set(CalculationBase(currencyCode: currencyCode, amount: amount))
            pipe.input.send(value: ())
        }
    }
}
