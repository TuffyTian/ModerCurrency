//
//  Api.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation

let acceessKey: String = "19447cab4770faa0861290ab0124944e"

struct Api {
    static let baseApi: String = "http://api.currencylayer.com"
}

extension Api {
    struct Currency {
        static var liveRate: String {
            return baseApi + "/live" + "?access_key=" + acceessKey
        }
        
        static var currencyList: String {
            return baseApi + "/list" + "?access_key=" + acceessKey
        }
    }
}


