//
//  CurrencyHomeItemViewModel.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation
import Combine

final class CurrencyHomeItemViewModel: ObservableObject, Identifiable {
    var id: Int
    var isSelected: Bool = false
    
    @Published var currency: Currency
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(id: Int, currency: Currency) {
        self.id = id
        self.currency = currency
        
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
