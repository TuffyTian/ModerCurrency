//
//  CurrencyHomeViewModelTests.swift
//  ModernCurrencyTests
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import XCTest
import Combine
@testable import ModernCurrency

class CurrencyHomeViewModelTests: XCTestCase {
    var mockService: MockCurrencyFetchService!
    var viewModel: CurrencyHomeViewModel!
    
    override func setUp() {
        mockService = MockCurrencyFetchService()
        viewModel = CurrencyHomeViewModel(dataSource: mockService)
    }
    
    func test_canLoadDataWhenFetchFailed() {
        let exp = expectation(description: "expected values")
        let cancelable = viewModel.$currencyList
            .sink { (items) in
                if items.count != 0 {
                    exp.fulfill()
                }
        }
        
        mockService.currencyListSubject.send(false)
        mockService.currencyListSubject.send(false)
        
        wait(for: [exp], timeout: 1)
        XCTAssert(viewModel.currencyList.count != 0)
        XCTAssert(viewModel.currencyShowing.count == 3)
    }
    
    func test_canLoadDataWhenFetchSuccess() {
        let exp = expectation(description: "expected values")
        let cancelable = viewModel.$currencyList
            .sink { (items) in
                if items.count != 0 {
                    exp.fulfill()
                }
        }
        
        mockService.currencyListSubject.send(true)
        mockService.currencyListSubject.send(true)
        
        wait(for: [exp], timeout: 1)
        XCTAssert(viewModel.currencyList.count != 0)
        XCTAssert(viewModel.currencyShowing.count == 3)
    }
    
    func test_addNewCurrencyShowing() {
        let expectCount = 4
        let exp = expectation(description: "expected values")
        let cancelable = viewModel.$currencyShowing
            .sink { (items) in
                if items.count == expectCount {
                    exp.fulfill()
                }
        }
        
        viewModel.addNewCurrencyShowing(key: "AMD")
        
        wait(for: [exp], timeout: 1)
        XCTAssert(viewModel.currencyShowing.count == 4)
    }
    
    func test_deleteCurrencyShowing() {
        let expectCount = 2
        let exp = expectation(description: "expected values")
        let cancelable = viewModel.$currencyShowing
            .sink { (items) in
                if items.count == expectCount {
                    exp.fulfill()
                }
        }
        
        viewModel.removeCurrencyShowing(at: 0)
        
        wait(for: [exp], timeout: 1)
        XCTAssert(viewModel.currencyShowing.count == 2)
    }
    
    func test_searchCurrency() {
        let expectCurrency = "AMD"
        let exp = expectation(description: "expected values")
        let cancelable = viewModel.$currencyList
            .sink { (items) in
                if items.first?.key == expectCurrency {
                    exp.fulfill()
                }
        }
        
        viewModel.searchText = "AMD"
        
        wait(for: [exp], timeout: 1)
        XCTAssert(viewModel.currencyList.count != 0)
    }
    
}
