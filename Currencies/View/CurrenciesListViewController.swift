//
//  ViewController.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit
import ReactiveSwift

class CurrenciesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let viewModel: CurrenciesListViewModel = CurrenciesListViewModelImpl()

    private var reloadSubscription: ScopedDisposable<AnyDisposable>?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToViewModel()
    }

    func subscribeToViewModel() {
        reloadSubscription = ScopedDisposable(opt:
            viewModel.reloads.observeValues { [weak self] in
                self?.tableView.reloadData()
            }
        )
    }

}

extension CurrenciesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CurrencyCell = tableView.dequeueCell(for: indexPath)
        cell.viewModel = viewModel.cells[indexPath.row]
        return cell
    }
}

