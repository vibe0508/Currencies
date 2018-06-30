//
//  ReactiveSwift+Extensions.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import ReactiveSwift

extension ScopedDisposable {
    convenience init?(_ disposable: Disposable?) {
        guard let disposable = disposable else {
            return nil
        }
        self.init(disposable)
    }
}
