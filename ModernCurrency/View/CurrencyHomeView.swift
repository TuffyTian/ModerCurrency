//
//  CurrencyHomeView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencyHomeView: View {
    @State var presentView = false
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        NavigationView {
            List {
                ForEach((1...30), id: \.self) { item in
                    CurrencyHomeItemView(textValue: .constant("120"))
                }
            }
            .navigationBarTitle("Currency")
            .navigationBarItems(trailing:
                Button(action: {
                    self.presentView.toggle()
                }) {
                    Image(systemName: "plus.circle").imageScale(.large)
                }
            )
            .sheet(isPresented: $presentView) {
                CurrencySelectionView(searchText: .constant(""))
            }
            .gesture(DragGesture().onChanged({_ in
                UIApplication.shared.endEditing()
            }))
            .padding(.bottom, keyboard.currentHeight)
            .animation(.easeOut(duration: 0.16))
        }
    }
}

struct CurrencyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyHomeView()
    }
}
