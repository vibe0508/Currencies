//
//  CurrencyCell.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class CurrencyCell: UITableViewCell {

    @IBOutlet private weak var symbolicIconView: UILabel!
    @IBOutlet private weak var currencyCodeLabel: UILabel!
    @IBOutlet private weak var currencyTitleLabel: UILabel!
    @IBOutlet private weak var amountField: UITextField!

    var viewModel: CurrencyCellViewModel? {
        didSet {
            viewModelWasUpdated()
        }
    }

    private var viewModelSubscription = CompositeDisposable()

    private func viewModelWasUpdated() {
        viewModelSubscription.dispose()
        viewModelSubscription = CompositeDisposable()

        currencyCodeLabel.text = viewModel?.currencyCode

        guard let viewModel = viewModel else {
            return
        }

        viewModelSubscription += symbolicIconView.reactive.text <~ viewModel.symbolicIcon
        viewModelSubscription += currencyTitleLabel.reactive.text <~ viewModel.currencyTitle
        viewModelSubscription += amountField.reactive.text <~ viewModel.amountText
        viewModelSubscription += amountField.reactive.continuousTextValues.observe(viewModel.userInputObserver)
        viewModelSubscription += amountField.reactive.controlEvents(.editingDidBegin).map {
            $0.text
        }.observe(viewModel.userInputObserver)
    }
}
