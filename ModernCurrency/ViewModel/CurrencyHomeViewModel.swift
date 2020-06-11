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
    private var currencyShowingKeys: [String] = ["USD", "CNY", "JPY"]
    @Published var currencyShowing: [CurrencyHomeItemViewModel] = []
    @Published var currentChangedCurrency: CurrencyHomeItemViewModel?
    
    
    /// This is datasource of the CurrencySelectionView. for conevenient, I just use a dict.
    @Published var currencyList: Dictionary<String, String> = [:]
    @Published var searchText: String = ""
    @Published var presentView = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        prepareData()
        
        NotificationCenter
            .default
            .addObserver(self,
                     selector: #selector(changeAmount(_:)),
                     name: NSNotification.Name("AmountChange"),
                     object: nil)
    }
    
    func addNewCurrencyShowing(key: String) {
        self.currencyShowingKeys.append(key)
    }
    
    @objc func changeAmount(_ notification: Notification) {
        DispatchQueue.main.async{ [unowned self] in
            for item in self.currencyShowing {
                if item.id != self.currentChangedCurrency?.id {
                    var toUSD: Double = 0.0
                    if self.currentChangedCurrency?.currency.currencyShort == "USD" {
                        toUSD = Double(self.currentChangedCurrency!.currency.amount) ?? 0.0
                    } else {
                        toUSD = (Double(self.currentChangedCurrency!.currency.amount) ?? 0.0) / self.currentChangedCurrency!.currency.rate
                    }

                    item.currency.amount = toUSD == 0.0 ? "" : String(format: "%.2f", (item.currency.rate * toUSD))
                }
            }
        }
    }
    
    private func prepareData() {
        self.$currentChangedCurrency
            .sink { (viewModel) in
                self.currencyShowing.forEach { (item) in
                    if item.id != viewModel?.id {
                        item.isSelected = false
                    } else {
                        item.isSelected = true
                    }
                }
            }
            .store(in: &cancelBag)
        
        CurrencyFetchManager.instance.$currenyListUpdated
            .combineLatest(CurrencyFetchManager.instance.$liveRateUpdated)
            .map { data -> [CurrencyHomeItemViewModel] in
                if data.0 == true && data.1 == true {
                    return self.loadCurrencies()
                }
                return []
            }
            .map({ (items) -> [CurrencyHomeItemViewModel] in
                items.filter { (item) -> Bool in
                    self.currencyShowingKeys.contains(item.currency.currencyShort)
                }
            })
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
        
        $searchText
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { self.filterWithSearchText($0)}
            .receive(on: DispatchQueue.main)
            .assign(to: \.currencyList, on: self)
            .store(in: &cancelBag)
    }
}

extension CurrencyHomeViewModel {
    private func loadCurrencies() -> [CurrencyHomeItemViewModel] {
        var currencyItemsShowing: [CurrencyHomeItemViewModel] = []
        
        let rates = UserDefaults.standard.dictionary(forKey: "rates") ?? [:]
        let currencies = UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
        for (index, currency) in currencies.enumerated() {
            let rateDic = rates.filter { (item) -> Bool in
                return item.key.contains(currency.key)
            }.first
            
            let currencyItem = Currency(id: index,
                                        rate: rateDic?.value as? Double ?? 0.0,
                                        amount: "",
                                        currencyShort: currency.key,
                                        currencyTitle: currency.value)
            
            currencyItemsShowing.append(CurrencyHomeItemViewModel(id: index, currency: currencyItem))
        }
        
        return currencyItemsShowing
    }
    
    private func filterWithSearchText(_ text: String) -> Dictionary<String, String> {
        let listDic = UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
        
        if text == "" {
            return listDic
        }
        return listDic.filter { (item) -> Bool in
            return item.key.lowercased().contains(text.lowercased()) || item.value.lowercased().contains(text.lowercased())
        }
    }
}
