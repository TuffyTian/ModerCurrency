//
//  CurrencyHomeItemViewModel.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation
import Combine

final class CurrencyHomeItemViewModel: ObservableObject {
    var isSelected: Bool
    
    @Published var currency: Currency
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(currency: Currency, isSelected: Bool) {
        self.currency = currency
        self.isSelected = isSelected
        
        prepareData()
    }
    
    private func prepareData() {
        $currency
            .sink { (value) in
                if self.isSelected {
                    NotificationCenter
                        .default
                        .post(name: NSNotification.Name("AmountChange"),
                              object: value,
                              userInfo: ["amount": self.currency.amount])
                }
        }
        .store(in: &cancelBag)
    }
}
