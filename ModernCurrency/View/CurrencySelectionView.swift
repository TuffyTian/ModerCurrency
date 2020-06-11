//
//  CurrencySelectionView.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import SwiftUI

struct CurrencySelectionView: View {
    @Binding var searchText: String
    
    var body: some View {
           VStack {
               HStack {
                   HStack {
                       Image(systemName: "magnifyingglass")

                       TextField("search", text: $searchText, onCommit: {
                           UIApplication.shared.endEditing()
                       })
                        .foregroundColor(.primary)

                       Button(action: {
                           self.searchText = ""
                       }) {
                        Image(systemName: "xmark.circle.fill")
                            .opacity(self.searchText == "" ? 0 : 1)
                       }
                   }
                   .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 6))
                   .foregroundColor(.secondary)
                   .background(Color(.secondarySystemBackground))
                   .cornerRadius(10.0)
               }
               .padding()
    
               List {
                ForEach((1...30), id: \.self) { item in
                       HStack {
                        Text(String(item))
                       }
                       .padding(.all, 10)
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
        CurrencySelectionView(searchText: .constant("1"))
    }
}
