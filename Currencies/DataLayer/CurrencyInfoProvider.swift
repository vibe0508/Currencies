//
//  CurrencyInfoProvider.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

protocol CurrencyInfoProviderWrapper {
    //let assume that we might fetch this data from network
    func currencyInfo(for code: String, completion: @escaping (CurrencyInfo) -> ())
}

class CurrencyInfoProvider {
    static let localesByCurrencyId: [String: Locale] = {
        var dict: [String: [Locale]] = [:]
        Locale.isoRegionCodes.forEach {
            let identifier = Locale.identifier(fromComponents: [
                NSLocale.Key.countryCode.rawValue: $0,
                NSLocale.Key.languageCode.rawValue: "en"
                ])
            let locale = Locale(identifier: identifier)
            guard let currencyCode = locale.currencyCode else {
                return
            }
            dict[currencyCode] = (dict[currencyCode] ?? []) + [locale]
        }
        return dict.mapValues { $0.bestMatchingCountryAndCorruncyCodes() }
    }()
}

extension CurrencyInfoProvider: CurrencyInfoProviderWrapper {
    func currencyInfo(for code: String, completion: @escaping (CurrencyInfo) -> ()) {

        DispatchQueue.global(qos: .background).async {

            if code == "EUR" {
                completion(CurrencyInfo(code: "EUR", name: "Euro", symbolicIcon: "🇪🇺"))
                return
            }

            guard let locale = CurrencyInfoProvider.localesByCurrencyId[code] else {
                return
            }

            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyPlural
            formatter.locale = locale

            guard let name = formatter.string(from: 1)?.components(separatedBy: " ").last?.capitalized else {
                return
            }

            let symbolicIcon = (locale.regionCode?
                .unicodeScalars
                .compactMap {
                    UnicodeScalar(127397 + $0.value)
                }
                .compactMap { Character($0) } as [Character]? )
                .flatMap { String($0) }

            let info = CurrencyInfo(code: code, name: name, symbolicIcon: symbolicIcon)

            completion(info)
        }
    }
}

private extension Array where Element == Locale {
    func bestMatchingCountryAndCorruncyCodes() -> Locale {
        return first(where: startsSame) ?? first(where: countryCodeContained) ?? first!
    }

    private func startsSame(_ locale: Locale) -> Bool {
        guard let countryCode = locale.regionCode,
            let currencyCode = locale.currencyCode else {
            return false
        }
        return currencyCode.starts(with: countryCode)
    }

    private func countryCodeContained(_ locale: Locale) -> Bool {
        guard let countryCode = locale.regionCode,
            let currencyCode = locale.currencyCode else {
                return false
        }
        return currencyCode.contains(countryCode)
    }
}
