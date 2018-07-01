//
//  RatesRequestor.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Result
import Reachability
import ReactiveSwift

protocol RatesRequestorWrapper {
    var state: SignalProducer<RatesRequestor.State, NoError> { get }
    func set(_ baseCurrency: String)
    func start()
    func stop()
}

class RatesRequestor: RatesRequestorWrapper {

    enum State {
        case noValue
        case hasValue(ExchangeRatesResponse)
        case error(Error)
    }

    private let queue = DispatchQueue(label: "FetchingRates", qos: .background)
    private let network: NetworkWrapper
    private let reachability: ReachabilityWrapper?

    private let _state = MutableProperty<State>(.noValue)

    private var baseCurrency = Configuration.Policy.startupBase.currencyCode
    private var lastSuccessfulLoad = Date()
    private var isStopped = true

    convenience init() {
        self.init(network: AlamofireWrapper(),
                  reachability: Reachability())
    }

    init(network: NetworkWrapper, reachability: ReachabilityWrapper?) {
        self.network = network
        self.reachability = reachability
    }

    var state: SignalProducer<State, NoError> {
        return _state.producer
    }

    func set(_ baseCurrency: String) {
        queue.async {
            self.baseCurrency = baseCurrency
        }
    }

    func start() {
        queue.async { [weak self] in
            guard let `self` = self,
                self.isStopped else {
                return
            }
            self.isStopped = false
            self.refresh()
        }
    }

    func stop() {
        queue.async { [weak self] in
            self?.isStopped = true
        }
    }

    private func refresh() {
        guard !isStopped else {
            return
        }

        network.perform(.currencies(with: baseCurrency), responseOn: queue, completion: { [weak self] (resp: ExchangeRatesResponse) in
            self?._state.value = .hasValue(resp)
            self?.lastSuccessfulLoad = Date()
            self?.scheduleNextRefresh()
        }, failure: { [weak self] error in
            self?.processError(error)
        })
    }

    private func processError(_ error: Error) {

        if -lastSuccessfulLoad.timeIntervalSinceNow >= Configuration.Policy.maxCacheLifetime {
            _state.value = .error(error)
        }

        guard let urlError = error as? URLError, urlError.code == .notConnectedToInternet else {
            scheduleNextRefresh()
            return
        }

        var needsCacheInvalidate = true

        let whenConnectionAppears = { [weak self] in
            self?.reachability?.whenReachable = nil
            needsCacheInvalidate = false
            self?.refresh()
        }

        reachability?.whenReachable = { [weak self] _ in
            self?.queue.async(execute: whenConnectionAppears)
        }

        let invalidateAfter = lastSuccessfulLoad
            .addingTimeInterval(Configuration.Policy.maxCacheLifetime)
            .timeIntervalSinceNow
        queue.asyncAfter(deadline: .now() + invalidateAfter) { [weak self] in
            guard needsCacheInvalidate else {
                return
            }
            self?._state.value = .error(error)
        }
    }

    private func scheduleNextRefresh() {
        queue.asyncAfter(deadline: .now() + Configuration.Policy.refreshRate) { [weak self] in
            self?.refresh()
        }
    }
}
