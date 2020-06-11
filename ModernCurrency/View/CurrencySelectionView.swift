//
//  CurrencySelectionView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencySelectionView: View {
    @ObservedObject var viewModel: CurrencyHomeViewModel
    
    var body: some View {
           VStack {
               HStack {
                   HStack {
                       Image(systemName: "magnifyingglass")

                       TextField("search", text: $viewModel.searchText, onCommit: {
                        UIApplication.shared.endEditing()
                        
                       })
                        .foregroundColor(.primary)

                       Button(action: {
                        self.viewModel.searchText = ""
                       }) {
                        Image(systemName: "xmark.circle.fill")
                            .opacity(viewModel.searchText == "" ? 0 : 1)
                       }
                   }
                   .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 6))
                   .foregroundColor(.secondary)
                   .background(Color(.secondarySystemBackground))
                   .cornerRadius(10.0)
               }
               .padding()
    
                List {
                    ForEach(viewModel.currencyList
                        .map({ $0.key })
                        .sorted(), id: \.self) { key in
                        HStack {
                            Text(key)
                                .fontWeight(.bold)
                            Text(self.viewModel.currencyList[key] ?? "")
                        }
                        .frame(height: 30)
                        .padding(.all, 10)
                        .onTapGesture {
                            self.viewModel.addNewCurrencyShowing(key: key)
                            self.viewModel.presentView = false
                        }
                        
                    }
                }
               .gesture(DragGesture().onChanged({_ in
                   UIApplication.shared.endEditing()
               }))
           }
    }
}

struct CurrencySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelectionView(viewModel: CurrencyHomeViewModel())
    }
}
