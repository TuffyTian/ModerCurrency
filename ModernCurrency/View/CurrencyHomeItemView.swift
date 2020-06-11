//
//  CurrencyHomeItemView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencyHomeItemView: View {
    @Binding var textValue: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Amercian USD")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            HStack {
                Text("USD")
                    .font(.system(size: 20))
                Spacer()
                TextField("0", text: $textValue)
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
        CurrencyHomeItemView(textValue: .constant("123"))
    }
}
