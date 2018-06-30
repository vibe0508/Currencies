//
//  UITableView+Extensions.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = String(describing: T.self).components(separatedBy: ".").last!
        return dequeueReusableCell(withIdentifier: reuseIdentifier,
                                   for: indexPath) as! T
    }
}
