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
    
    private var reloadDataSubject = CurrentValueSubject<Bool, Never>(true)
    private var refetchDataSubject = PassthroughSubject<Void, Never>()
    
    /// This is datasource of the CurrencySelectionView. for conevenient, I just use a dict.
    @Published var currencyList: Dictionary<String, String> = [:]
    @Published var searchText: String = ""
    @Published var presentView = false
    
    private var cancelBag = Set<AnyCancellable>()
    private let currencyFetchDataSource: CurrencyFetchDataSource
    
    init(dataSource: CurrencyFetchDataSource) {
        currencyFetchDataSource = dataSource
        prepareData()
        
        NotificationCenter
            .default
            .addObserver(self,
                     selector: #selector(changeAmount(_:)),
                     name: NSNotification.Name(amountChangeNotificationName),
                     object: nil)
        
        DispatchTimer(timeInterval: 900) { (timer) in
            self.refetchDataSubject.send()
        }
    }
    
    // add new currency to home page
    func addNewCurrencyShowing(key: String) {
        self.currencyShowingKeys.append(key)
        reloadDataSubject.send(true)
    }
    
    // remove currency from home page
    func removeCurrencyShowing(at index: Int) {
        self.currencyShowingKeys.remove(at: index)
        reloadDataSubject.send(true)
    }
    
    // change amount. will change amounts of all of the currenies at home page
    @objc func changeAmount(_ notification: Notification) {
        DispatchQueue.main.async{ [unowned self] in
            for item in self.currencyShowing {
                if item.currency.currencyShort != self.currentChangedCurrency?.currency.currencyShort {
                    var toUSD: Double = 0.0
                    if self.currentChangedCurrency?.currency.currencyShort == "USD" {
                        toUSD = Double(self.currentChangedCurrency!.currency.amount) ?? 0.0
                    } else {
                        toUSD = (Double(self.currentChangedCurrency!.currency.amount) ?? 0.0) / self.currentChangedCurrency!.currency.rate
                    }
                    
                    if item.currency.currencyShort == "USD" {
                        item.currency.amount = toUSD == 0.0 ? "" : String(format: "%.2f", (toUSD))
                    } else {
                        item.currency.amount = toUSD == 0.0 ? "" : String(format: "%.2f", (item.currency.rate * toUSD))
                    }
                }
            }
        }
    }
    
    // add subscribers
    private func prepareData() {
        self.$currentChangedCurrency
            .sink { (viewModel) in
                self.currencyShowing.forEach { (item) in
                    item.isSelected = item.currency.currencyShort == viewModel?.currency.currencyShort
                }
            }
            .store(in: &cancelBag)
        
        self.refetchDataSubject
            .flatMap {
                return self.currencyFetchDataSource.currenyListUpdated
                    .combineLatest(self.currencyFetchDataSource.liveRateUpdated)
                .replaceError(with: (false, false))
                .eraseToAnyPublisher()
            }
            .map { (result) -> Bool in
                return result.0 == true && result.1 == true
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.reloadDataSubject.value, on: self)
            .store(in: &cancelBag)
        
        self.reloadDataSubject
            .filter { $0 == true }
            .map { data -> [CurrencyHomeItemViewModel] in
                return self.loadCurrencies()
            }
            .map({ (items) -> [CurrencyHomeItemViewModel] in
                return self.filterWithCurrenyShowingKeys(items: items)
            })
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: \.currencyShowing, on: self)
            .store(in: &cancelBag)
            
        self.reloadDataSubject
            .filter { $0 == true }
            .map { data -> Dictionary<String, String> in
                return UserDefaults.standard.dictionary(forKey: currencyStoreKey) as? Dictionary<String, String> ?? [:]
            }
            .map { items in
                return items.filter({ (item) -> Bool in
                    return !self.currencyShowingKeys.contains(item.key)
                })
            }
            .receive(on: DispatchQueue.main)
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
    // load data from local
    private func loadCurrencies() -> [CurrencyHomeItemViewModel] {
        var currencyItemsShowing: [CurrencyHomeItemViewModel] = []
        
        let rates = UserDefaults.standard.dictionary(forKey: liveRateStoreKey) ?? [:]
        let currencies = UserDefaults.standard.dictionary(forKey: currencyStoreKey) as? Dictionary<String, String> ?? [:]
        if rates.count == 0 || currencies.count == 0 {
            self.refetchDataSubject.send()
            return []
        }
        
        for (index, currency) in currencies.enumerated() {
            let rateDic = rates.filter { (item) -> Bool in
                return item.key.contains(currency.key)
            }.first
            
            let currencyItem = Currency(id: index,
                                        rate: rateDic?.value as? Double ?? 0.0,
                                        amount: "",
                                        currencyShort: currency.key,
                                        currencyTitle: currency.value)
            
            if self.currentChangedCurrency?.currency.currencyShort == currencyItem.currencyShort {
                let specialViewModel = CurrencyHomeItemViewModel(currency: currencyItem, isSelected: true)
                currencyItemsShowing.append(specialViewModel)
                self.currentChangedCurrency = specialViewModel
            } else {
                currencyItemsShowing.append(CurrencyHomeItemViewModel(currency: currencyItem, isSelected: false))
            }
        }
        
        return currencyItemsShowing
    }
    
    private func filterWithCurrenyShowingKeys(items: [CurrencyHomeItemViewModel]) -> [CurrencyHomeItemViewModel] {
        var newCurrencyItems: [CurrencyHomeItemViewModel] = []
        for key in self.currencyShowingKeys {
            let item = items.filter { (item) -> Bool in
                item.currency.currencyShort.contains(key)
            }.first ?? nil
            
            guard let newItem = item else {
                break
            }
            newCurrencyItems.append(newItem)
        }
        return newCurrencyItems
    }
    
    private func filterWithSearchText(_ text: String) -> Dictionary<String, String> {
        var listDic = UserDefaults.standard.dictionary(forKey: currencyStoreKey) as? Dictionary<String, String> ?? [:]
        
        listDic = listDic.filter({ (item) -> Bool in
            return !currencyShowingKeys.contains(item.key)
        })
        
        if text == "" {
            return listDic
        }
        return listDic.filter { (item) -> Bool in
            return item.key.lowercased().contains(text.lowercased()) || item.value.lowercased().contains(text.lowercased())
        }
    }
}

extension CurrencyHomeViewModel {
    private func DispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->()) {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            handler(timer)
        }
        timer.resume()
    }
}
