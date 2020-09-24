//
//  DetialView.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/8/25.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI


struct DetialView: View {
    
    let title: String
    
    
    @Binding var beginTime: String
    @Binding var endTime: String
    
    @State var showDateCalender = false
    
    var body: some View {
        NavigationView {
            VStack {
                ActionItemView(currentTime: $beginTime, model: .init(beginTime: "abc", endTime: "ecd", date: "abde"), labelText: "上班时间").frame(height: 80, alignment: .leading)
                
                ActionItemView(currentTime: $endTime, model: .init(beginTime: "abc", endTime: "ecd", date: "abde"), labelText: "下班时间").frame(height: 80, alignment: .leading)
                
                Spacer()
            }
            
            
        }.navigationBarTitle(Text(title), displayMode: .inline)
        
    }
}

struct ActionItemView: View {
    
    @Binding var currentTime: String
    var model: DateModel
    
    let labelText: String
    
    @State var showDateCalender = false
    
    @State var currentDate = Date()
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                HStack {
                    Text(labelText)
                    Spacer()
                    Button(action: { 
                        self.currentTime = self.model.currentTime
                        self.showDateCalender.toggle()
                    }) { 
                        Text("打卡abc")
                    }
                }.padding(.bottom, 10)
                Button(action: { 
                    self.currentTime = "请假"
                    
                }) { 
                    Text(currentTime)
                }
                
                Spacer()
                
            }
        }.padding()
    }
}



struct DetialView_Previews: PreviewProvider {
    
    //    @State var model = DateModel(beginTime: "", endTime: "", date: "")
    
    static var previews: some View {
        DetialView(title: "", beginTime: .constant(""), endTime: .constant(""))
        //        DetialView(
        //        DetialView(title: "abc", model: )
        //        DetialView(title: "", model: .constant(.init(beginTime: "", endTime: "", date: "")))
        //        DetialView(title: "title", model: .init(beginTime: "", endTime: "", date: ""))
        //        ActionItemView(currentTime: "9：00", model: .init(beginTime: "abc", endTime: "ecd", date: "abde"))
    }
}
