//
//  CurrencyHomeItemView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencyHomeItemView: View {
    @ObservedObject var viewMode: CurrencyHomeItemViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewMode.currency.currencyTitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            HStack {
                Text(viewMode.currency.currencyShort)
                    .font(.system(size: 20))
                Spacer()
                TextField("0", text: $viewMode.currency.amount)
                    .font(.system(size: 20))
                    .padding(.leading, 10)
            }
        }
        .padding(.all, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color.init(hex: 0xF6F4F8))
            }
        )
    }
}

struct CurrencyHomeItemView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyHomeItemView(viewMode: CurrencyHomeItemViewModel(currency: Currency(id: 0, rate: 0, amount: "", currencyShort: "", currencyTitle: ""), isSelected: false))
    }
}
