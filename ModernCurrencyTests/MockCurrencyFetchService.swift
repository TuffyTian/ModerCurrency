//
//  MockCurrencyFetchManager.swift
//  ModernCurrencyTests
//
//  Created by TuffyTian on 2020/6/12.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import XCTest
import Combine
@testable import ModernCurrency

class MockCurrencyFetchService: CurrencyFetchDataSource {
    let currencyListSubject = CurrentValueSubject<Bool, AppError>(false);
    let liveRateSubject = CurrentValueSubject<Bool, AppError>(false)
    var currenyListUpdated: AnyPublisher<Bool, AppError> {
        return currencyListSubject.eraseToAnyPublisher()
    }
    
    var liveRateUpdated: AnyPublisher<Bool, AppError> {
        return liveRateSubject.eraseToAnyPublisher()
    }
}
