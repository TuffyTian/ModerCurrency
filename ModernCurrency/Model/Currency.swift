//
//  Currency.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation

struct Currency: Identifiable, Codable {
    var id: Int
    var rate: Double
    var amount: String = ""
    //The short of currency
    var currencyShort: String = ""
    //The name of currency
    var currencyTitle: String = ""
    
    init(id: Int, rate: Double, amount: String, currencyShort: String, currencyTitle: String) {
        self.id = id
        self.rate = rate
        self.amount = amount
        self.currencyShort = currencyShort
        self.currencyTitle = currencyTitle
    }
    
}
