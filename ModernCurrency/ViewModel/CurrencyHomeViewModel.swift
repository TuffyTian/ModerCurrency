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
    private var reloadSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    private var refetchDataSubject = PassthroughSubject<Void, Never>()
    
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
                     name: NSNotification.Name(amountChangeNotificationName),
                     object: nil)
        
        DispatchTimer(timeInterval: 900) { (timer) in
            self.refetchDataSubject.send()
        }
    }
    
    func addNewCurrencyShowing(key: String) {
        self.currencyShowingKeys.append(key)
        
        reloadSubject.send(true)
    }
    
    func removeCurrencyShowing(at index: Int) {
        self.currencyShowingKeys.remove(at: index)
        
        reloadSubject.send(true)
    }
    
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
                    
                    print(item.currency.amount + "\(item.currency.currencyShort)")
                }
            }
        }
    }
    
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
                return CurrencyFetchManager.instance.currenyListUpdated
                    .combineLatest(CurrencyFetchManager.instance.liveRateUpdated)
                .replaceError(with: (false, false))
                .eraseToAnyPublisher()
            }
            .map { (result) -> Bool in
                if result.0 == true && result.1 == true {
                    return true
                } else {
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.reloadSubject.value, on: self)
            .store(in: &cancelBag)
        
        self.reloadSubject
            .filter { $0 == true }
            .map { data -> [CurrencyHomeItemViewModel] in
                return self.loadCurrencies()
            }
            .map({ (items) -> [CurrencyHomeItemViewModel] in
                print(items.count)
                return self.filterWithCurrenyShowingKeys(items: items)
            })
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: \.currencyShowing, on: self)
            .store(in: &cancelBag)
            
        self.reloadSubject
            .filter { $0 == true }
            .map { data -> Dictionary<String, String> in
                if data == true {
                    return UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
                }
                return [:]
            }
            .map { items in
                return items.filter({ (item) -> Bool in
                    return !self.currencyShowingKeys.contains(item.key)
                })
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
        if rates.count == 0 || currencies.count == 0 {
            CurrencyFetchManager.instance.refetchDataSubject.send()
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
        var listDic = UserDefaults.standard.dictionary(forKey: "currency") as? Dictionary<String, String> ?? [:]
        
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
