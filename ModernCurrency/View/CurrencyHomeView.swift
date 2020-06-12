//
//  CurrencyHomeView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencyHomeView: View {
    @ObservedObject private var keyboard = KeyboardResponder()
    @ObservedObject var viewModel: CurrencyHomeViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.currencyShowing, id: \.currency.currencyShort) { item in
                    CurrencyHomeItemView(viewMode: item)
                        .onTapGesture {
                            self.viewModel.currentChangedCurrency = item
                    }
                }
                .onDelete(perform: removeItems(at:))
            }
            .navigationBarTitle("Currency")
            .navigationBarItems(trailing:
                Button(action: {
                    self.viewModel.presentView.toggle()
                }) {
                    Image(systemName: "plus.circle").imageScale(.large)
                }
            )
            .sheet(isPresented: $viewModel.presentView) {
                CurrencySelectionView(viewModel: self.viewModel)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .gesture(DragGesture().onChanged({_ in
                UIApplication.shared.endEditing()
            }))
            .padding(.bottom, keyboard.currentHeight)
            .animation(.easeOut(duration: 0.16))
        }
    }
    
    private func removeItems(at offsets: IndexSet) {
//        viewModel.currencyList.remove(at: offsets.first)
        viewModel.removeCurrencyShowing(at: offsets.first!)
    }
}

struct CurrencyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyHomeView(viewModel: CurrencyHomeViewModel(service: CurrencyFetchService()))
    }
}
