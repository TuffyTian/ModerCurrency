//
//  CurrencyHomeViewModel.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation
import Combine

final class CurrencyHomeViewModel: ObservableObject {
    
    /// This is a array of currnecy you have selected to show at homepage
    @Published var currencyShowing: [CurrencyHomeItemViewModel] = []
    
    /// This is datasource of the CurrencySelectionView. for conevenient, I just use a dict.
    @Published var currencyList: Dictionary<String, String> = [:]
    @Published var searchText: String = ""
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        prepareData()
    }
    
    private func prepareData() {
        CurrencyFetchManager.instance.$currenyListUpdated
            .combineLatest(CurrencyFetchManager.instance.$liveRateUpdated)
            .tryMap { data -> [CurrencyHomeItemViewModel] in
                var currencyItemsShowing: [CurrencyHomeItemViewModel] = []
                
                if data.0 == true && data.1 == true {
                    let rates = UserDefaults.standard.dictionary(forKey: "rates") ?? [:]
                    let currencies = UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
                    for (index, currency) in currencies.enumerated() {
                        let rateDic = rates.filter { (item) -> Bool in
                            return item.key.contains(currency.key)
                        }.first
                        
                        currencyItemsShowing.append(CurrencyHomeItemViewModel())
                    }
                }
                return currencyItemsShowing
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: \.currencyShowing, on: self)
            .store(in: &cancelBag)
        
        CurrencyFetchManager.instance.$currenyListUpdated
            .map { data -> Dictionary<String, String> in
                if data == true {
                    return UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
                }
                return [:]
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: [:])
            .assign(to: \.currencyList, on: self)
            .store(in: &cancelBag)
    }
}
