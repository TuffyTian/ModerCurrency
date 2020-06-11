//
//  CurrencyFetchManager.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation
import Combine

final class CurrencyFetchManager {
    static let instance = CurrencyFetchManager()
    
    private init() {
        // fet live rate every 15 minutes.
        DispatchTimer(timeInterval: 900) { [unowned self] (timer) in
            self.fetchLiveRate()
            self.fetchCurrencyList()
        }
        
        refetchDataSubject.sink { () in
            self.fetchCurrencyList()
            self.fetchLiveRate()
        }
        .store(in: &cancelBag)
    }
    
    private var cancelBag = Set<AnyCancellable>()
    @Published var currenyListUpdated = false
    @Published var liveRateUpdated = false
    
    var refetchDataSubject = PassthroughSubject<Void, Never>()
}

extension CurrencyFetchManager {
    private func fetchCurrencyList() {
        let request = URLRequest(url: URL(string: Api.Currency.currencyList)!)
        
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .tryMap { (data) -> Bool in
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let json = jsonData else {
                    return false
                }
                // For convenient I use UserDefaults, Actually it is not a good way to store network data.
                // Data of curreny is not big. So just chose UserDefaults.
                let jsonDic = json as? Dictionary<String, Any> ?? [:]
                UserDefaults.standard.set(jsonDic["currencies"] ?? [], forKey: "currency")
                return true
            }
            .replaceError(with: false)
            .assign(to: \.currenyListUpdated, on: self)
            .store(in: &cancelBag)
    }
    
    private func fetchLiveRate() {
        let request = URLRequest(url: URL(string: Api.Currency.liveRate)!)
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .tryMap { (data) -> Bool in
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let json = jsonData else {
                    return false
                }
                // For convenient I use UserDefaults, Actually it is not a good way to store network data.
                // Data of curreny is not big. So just chose UserDefaults.
                let jsonDic = json as? Dictionary<String, Any> ?? [:]
                UserDefaults.standard.set(jsonDic["quotes"] ?? [], forKey: "rates")
                return true
            }
            .replaceError(with: false)
            .assign(to: \.liveRateUpdated, on: self)
            .store(in: &cancelBag)
    }
}

extension CurrencyFetchManager {
    public func DispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->()) {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            handler(timer)
        }
        timer.resume()
    }
}
