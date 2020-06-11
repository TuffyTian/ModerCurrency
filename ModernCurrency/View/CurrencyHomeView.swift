//
//  CurrencyHomeView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencyHomeView: View {
    var body: some View {
        List {
            ForEach((1...30), id: \.self) { item in
                CurrencyHomeItemView(textValue: .constant("120"))
            }
        }
    }
}

struct CurrencyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyHomeView()
    }
}
