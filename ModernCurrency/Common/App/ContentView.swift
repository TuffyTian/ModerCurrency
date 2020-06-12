//
//  ContentView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CurrencyHomeView(viewModel: CurrencyHomeViewModel(service: CurrencyFetchService()))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
