//
//  MainContentView.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/8/26.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI
struct MainContentView:  View{
    @State var beginTime = ""
    @State var endTime = ""
    
    @State var count = 10
    
    var listItems = ["a","b","c","d","e"]
    
    var body: some View {
        NavigationView {
            List{

                ForEach(0..<2) { (idx: Int) in
                    Text(idx.description)
                }
            }.navigationBarItems(trailing: EditButton())
        }
        
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
//        Text("")
    }
}
