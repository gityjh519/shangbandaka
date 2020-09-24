//
//  ContentView.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/8/18.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    
    @EnvironmentObject var model: DateItemModel
    
    @State var isAlert = false
    
    @State var alertTitle = ""
    @State var buttonAction: (()->Void)?
    
    @State var selectedSet = IndexSet.init()
    
    @State var isAlaterDate = false
    
    @State var index = 1
    
    @State var currentJson = DateModel(beginTime: "", endTime: "", date: "")
    
    @State var addItem = false
    
    @State var selectedList = Set<[Int]>()
    
    @State private var isShowDatePicker = false
    
    
    var body: some View {
        NavigationView {
            self.contentView
            
        }.alert(isPresented: $isAlert) { 
            Alert(title: Text(alertTitle), message: nil, primaryButton: .cancel(), secondaryButton: .default(Text("确定"), action: { 
                self.buttonAction?()
            }))
        }
    }
    
    /// 联系人关系图
    var contanctContentView: some View {
        NavigationLink(destination: MainContactView().environmentObject(ContentItemJson(name: "我的", contacts: ContentItemJson.ceateList()))) {
            Text("联系人")
        }.isDetailLink(false)
    }
    
    
    
    var contentView: some View {
        
        VStack {
            
            List{ 
                
                contanctContentView
                
                dateLabel
                
                summaryLabel
                
                ForEach(model.list) { (item: DateModel) in
                    
                    DateTimeItem(model: .constant(item), date: self.model.currentDate) { (idx) in
                        self.index = idx
                        self.isAlaterDate.toggle()
                        self.currentJson = item
                    }
                }.onDelete { (set: IndexSet) in
                    if let index = set.first {
                        let item = self.model.list[index]
                        self.tapGestureAction(item: item)
                    }
                }
                
            }.sheet(isPresented: self.$isAlaterDate) { 
                
                AlterDatePickerView(title: self.index == 1 ? "上班时间" : "下班时间",dateTime: self.currentJson.dateWeek!) { (date) in
                 
                    self.isAlaterDate.toggle()

                    self.changeCurrentTime(item: self.currentJson, index: self.index, date: date)

                    
                }
            }          
            ButtonItems(model: .constant(self.model)) { (tag) in
                
                if tag == 0 {
                    self.enterLocation()
                }else if tag == 1 {
                    self.outLocation()
                }

            }
        
            
            
            
        }.navigationBarTitle(Text("打卡记录"), displayMode: .inline).navigationBarItems(leading: Button(action: { 
                self.addItem.toggle()
            }, label: { 
                Text("+").font(Font.title)
            }), trailing: Button(action: { 
                self.qingJiaAM()
                
            }, label: { 
                Text("请假")
            })).sheet(isPresented: $addItem) { 
                
                EditNewItemDateView { (newItem: DateModel) in
                    self.model.list.insert(newItem, at: 0)
                    self.addItem.toggle()
                }
        }
        
        
    }
    
    var dateLabel: some View {
        HStack {
            Text("选择年月")
            Spacer()
            
            Button(action: { 
                self.isShowDatePicker.toggle()
            }) { 
                Text(self.model.yyyyMM)
            }.sheet(isPresented: self.$isShowDatePicker) { () in
                YYYYMMView { (value: String) in
                    self.model.yyyyMM = value
                    self.isShowDatePicker.toggle()
                }
            }
        }
    }
    
    var summaryLabel: some View {
        HStack {
            Text("加班统计")
            Spacer()
            if getAllExtenTimes() == "未加班" {
                Text(getAllExtenTimes())
            }else{
                Text(getAllExtenTimes()).foregroundColor(Color.red)
            }
        }
    }
    
 
    
    func getAllExtenTimes() -> String {
        let allTime = model.list.reduce(0) { (result, item) -> Int in
            result + item.externTimeInt
        }
        if allTime <= 0 {
            return "未加班"
        }
        return String(format: "%0.1f个小时", Double(allTime) / 2.0)
    }
    
}

struct YYYYMMView: View {
    @State var yyyyIndex = DateModel.ymList[0]
    @State var mmIndex = DateModel.ymList[1] - 1
    
    private let count: Int
    let doneSelectedDate: (_ value: String)->Void
    
    
    init(_ block: @escaping (_ value: String)->Void) {
        doneSelectedDate = block
        let formater = DateFormatter()
        formater.dateFormat = "yyyy"
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.calendar = .init(identifier: .gregorian)
        let value = formater.string(from: Date())
        count = Int(value)! - 2020 + 1
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(self.getValueDate()).padding(20)
                GeometryReader { (geo: GeometryProxy)  in
                    HStack(alignment: .center, spacing: 0.0) {
                        
                        Picker("", selection: self.$yyyyIndex) {
                            ForEach(0..<self.count) { (idx: Int) in
                                Text((2020 + idx).description + "年")
                            }
                            }.labelsHidden().frame(width: geo.size.width/2, alignment: .center).clipped().padding(0)
                        Picker("", selection: self.$mmIndex) {
                            ForEach(1..<13) { (idx: Int) in
                                Text(String(format: "%02d", idx) + "月")
                            }
                            }.labelsHidden().frame(width: geo.size.width/2, alignment: .center).clipped().padding(0)
                    }
                    Spacer()
                }.navigationBarTitle(Text("选择日期"), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                    self.doneSelectedDate(self.getValueDate())
                }, label: { 
                    Text("完成")
            }))
            }
        }
    }
    
    func getValueDate() -> String {
        let yyyy = (yyyyIndex + 2020).description + "年"
        let mm = String(format: "%02d", (mmIndex + 1)) + "月"
        return yyyy + mm
    }
}



extension ContentView {
    
    
    func changeCurrentTime(item: DateModel,index: Int,date: Date) {
        let formater = DateFormatter()
        formater.calendar = .init(identifier: .gregorian)
        formater.dateFormat = "HH:mm:ss"
        let hhmmss = formater.string(from: date)
        
        var beginTime = item.beginTime
        var endTime = item.endTime
        if index == 1 {
            beginTime = hhmmss
        }else if index == 2 {
            endTime = hhmmss
        }
        let json = DateModel(beginTime: beginTime, endTime: endTime, date: item.date)
        let idx = model.list.firstIndex { (subItem) -> Bool in
            subItem.id == item.id
        }
        if idx != nil {
            model.list[idx!] = json

        }
        
        
    }
    
    func tapGestureAction(item: DateModel) {
        let itemModel = model.list.first { (subItem) -> Bool in
            subItem.id == item.id
        }
        guard let selectedModel = itemModel else {
            return
        }
        alertTitle = "是否删除\(selectedModel.date ?? "")记录"
        buttonAction = {
            () in
            self.model.list.removeAll { (sItem) -> Bool in
                sItem.id == selectedModel.id
            }
        }
        isAlert.toggle()
    }
    
    
    
    func deleteLastDate() {
        
        if model.list.isEmpty {
            return
        }
        alertTitle = "是否删除\(self.model.list.first?.date ?? "")记录"
        buttonAction = {
            () in
            if self.model.list.count > 0 {
                self.model.list.removeLast()
            }
            
        }
        isAlert.toggle()
        
        
    }
    
    func enterLocation() {
        
        let json = model.list.first
        let count = 0
        
        let currentDate = model.currentDate
        
        if !currentDate.contains(json?.date ?? "ppd") {
            
            let nextjson = DateModel(beginTime: json?.currentTime, endTime: nil, date: currentDate)
            self.model.list.insert(nextjson, at: 0)
        }else {
            var next = DateModel(beginTime: json?.beginTime, endTime: json?.endTime, date: json?.date)
            
            if let time = json?.beginTime {
                alertTitle = "上班：重新打卡\(time)"
                buttonAction = {
                    () in
                    next.beginTime = json?.currentTime
                    self.model.list[count] = next
                }
                isAlert.toggle()
            }else {
                next.beginTime = json?.currentTime
                self.model.list[count] = next
                
            }
        }
    }
    
    func outLocation()  {
        
        if model.list.isEmpty {
            alertTitle = "请先打卡上班"
            buttonAction = nil
            isAlert.toggle()
            return
        }
        
        let json = model.list.first
        let count = 0
        
        let currentJson = DateModel(beginTime: json?.beginTime, endTime: json?.currentTime, date: json?.date)
        
        
        if let time = json?.endTime {
            alertTitle = "下班：重新打卡\(time)"
            isAlert.toggle()
            
            buttonAction = {
                () in
                self.model.list[count] = currentJson
            }
        }else {
            model.list[count] = currentJson
        }
    }
    func qingJiaAM() {
        
        let json = model.list.first
        let count = 0
        
        let currentDate = model.currentDate
        
        if !currentDate.contains(json?.date ?? "ppd") {
            
            let nextjson = DateModel(beginTime: "请假", endTime: "请假", date: currentDate)
            self.model.list.insert(nextjson, at: 0)
        }else {
            var next = DateModel(beginTime: "请假", endTime: "请假", date: json?.date)
            
            if json?.beginTime?.contains("请假") == false {
                alertTitle = (json?.date ?? "今天") + " 请假"
                buttonAction = {
                    () in
                    next.beginTime = "请假"
                    next.beginTime = "请假"
                    
                    self.model.list[count] = next
                }
                isAlert.toggle()
            }
        }
    }
    
    func qingjiaPM()  {
        
        let json = model.list.last
        let count = model.list.count - 1
        
        let currentDate = model.currentDate
        
        if !currentDate.contains(json?.date ?? "ppd") {
            
            let nextjson = DateModel(beginTime: "未打卡", endTime: nil, date: currentDate)
            self.model.list.append(nextjson)
        }else {
            var next = DateModel(beginTime: "请假", endTime: json?.endTime, date: json?.date)
            
            alertTitle = "今天下午请假"
            
            if json?.endTime?.contains("请假") == false {
                buttonAction = {
                    () in
                    next.endTime = "请假"
                    self.model.list[count] = next
                }
                isAlert.toggle()
            }
        }
        
    }
}

struct ButtonItems: View {
    private let listText = ["上班打卡","下班打卡"]
    
    @Binding var model: DateItemModel
    var finishedBlock: (_ tag: Int) -> Void
    
    
    var body: some View {
        HStack {
            
            ForEach(0..<listText.count) { index in
                self.createButton(index: index, title: self.listText[index])
            }
        }
    }
    
    func createButton(index: Int,title: String) -> some View {
        
        Button(action: { 
            self.finishedBlock(index)
        }) { 
            Text(title)
        }.padding()
    }
}





struct DateTimeItem: View {
    @Binding var model: DateModel
    let date: String
    var clickItem:((_ index: Int) -> Void)?
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(getCurrentDate()).foregroundColor(model.color).font(Font.system(size: 18, weight: .bold, design: .serif))
                Spacer()
                
            }.padding(.bottom, 12)
            
            HStack {
                Text(model.beginTimeValue).onTapGesture {
                    self.clickItem?(1)
                }.font(Font.system(size: 14))
                Spacer()
                Text(model.endTimeValue).onTapGesture {
                   self.clickItem?(2)
                }.font(Font.system(size: 14))
            }
            if model.externTime != nil{
                Text(model.externTime!).padding([.top,.bottom], 10).foregroundColor(Color.red).font(Font.system(size: 14, weight: .bold, design: .rounded))
            }
        }
    }
    
    func getCurrentDate() -> String {
        if let sDate = model.dateWeek {
            return sDate
        }
        return date
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView().environmentObject(DateItemModel())
        //        ContentView(isShowText: false, model: DateItemModel(), isAlert: false)
        
    }
}



struct AlterDatePickerView: View {
    @State var date = Date()
    let title: String
    let dateTime: String
    var finishedBlock: ((_ date: Date) -> Void)?
    var body: some View {
        NavigationView {
            VStack {
                
                Text(dateTime).font(Font.system(size: 20)).padding(.top, 40).foregroundColor(getColor())
                
                DatePicker(selection: $date, displayedComponents: .hourAndMinute) {
                    Text("")
                }.labelsHidden().navigationBarTitle(Text(title), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                    self.finishedBlock?(self.date)
                }, label: { 
                    Text("完成")
                    })).padding()
                Spacer()
            }
        }
    }
    
    func getColor() -> Color {
        let haveDate = dateTime.contains("星期六") || dateTime.contains("星期日")
        return haveDate ? Color.init(red: 219.0/255.0, green: 80.0/255.0, blue: 72.0/255.0) : Color(UIColor.label)
    }
    
}


struct EditNewDateView: View {
    @State var beginTime = ""
    @State var endTime = ""
    @State var dateString = ""
    @State var date = Date()
    @State var dateType = DatePickerComponents.date
    
    let finishedBlock: ((_ item: DateModel)->Void)
    
    var body: some View {
        NavigationView{
            List{
                
                HStack{
                    Button(action: { 
                        self.dateType = .date
                        self.dateString = self.getCurrentYMD(dateFormat: "yyyy年MM月dd日 EEEE")
                    }) { 
                        Text("上班日期")
                    }
                    Spacer()
                    
                    Text(self.dateString)
                }
                
                
                
                HStack {
                    Button(action: { 
                        self.dateType = .hourAndMinute
                        self.beginTime = self.getCurrentYMD(dateFormat: "HH:mm:ss")

                    }) { 
                        Text("上班时间")
                    }
                    Spacer()
                    
                    Text(self.beginTime)
                }
                
                HStack {
                    Button(action: { 
                        self.dateType = .hourAndMinute
                        self.endTime = self.getCurrentYMD(dateFormat: "HH:mm:ss")

                    }) { 
                        Text("下班时间")
                    }
                    
                    Spacer()
                    
                    Text(self.endTime)
                }
                
                timePicker
            }.navigationBarTitle(Text("添加一条"), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                
                let model = DateModel(beginTime: self.beginTime, endTime: self.endTime, date: self.dateString)
                self.finishedBlock(model)
                
            }, label: { 
                Text("完成")
            }))
        }
    }
    
    var timePicker: some View {
        DatePicker(selection: $date, displayedComponents: dateType) {
            Text("")
        }.labelsHidden()
    }
    
    
    func getCurrentYMD(dateFormat: String) -> String {
        let formater = DateFormatter()
        formater.calendar = .init(identifier: .gregorian)
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.dateFormat = dateFormat
        return formater.string(from: date)
            
            
    }

    
}



struct EditNewItemDateView: View {

    @State var date = Date()
    @State var dateType = DatePickerComponents.date
    
    let finishedBlock: ((_ item: DateModel)->Void)
    @State var timeList = ["X年X月X日","00:00","00:00","19:00"]
    let titles = ["上班日期","上班时间","下班时间","开始加班时间"]
    
    var body: some View {
        NavigationView{
            List{
                ForEach(self.titles, id: \.self) { (item) in
                    self.createCellItem(title: item)
                }
                timePicker
                
                
            }.navigationBarTitle(Text("添加一条"), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                
                let model = DateModel(beginTime: self.timeList[1], endTime: self.timeList[2], date: self.timeList[0])
                self.finishedBlock(model)
                
            }, label: { 
                Text("完成")
            }))
        }
    }
    
    func createCellItem(title: String) -> some View {
        
        let index = titles.firstIndex(of: title)!
        let newvalue = timeList[index]
        
        return HStack {
            Button(action: { 
                if index == 0 {
                    self.dateType = .date
                    self.timeList[index] = self.getCurrentYMD(dateFormat: "yyyy年MM月dd日 EEEE")
                }else {
                    self.dateType = .hourAndMinute
                    if index == 3 {
                        self.timeList[index] = self.getCurrentYMD(dateFormat: "HH:mm")

                    }else {
                        self.timeList[index] = self.getCurrentYMD(dateFormat: "HH:mm:ss")
                    }
                }

            }) { 
                Text(title)
            }
            Spacer()
            Text(newvalue)
        }
    }
    
    var timePicker: some View {
        DatePicker(selection: $date, displayedComponents: dateType) {
            Text("")
        }.labelsHidden()
        
    }
    
    
    func getCurrentYMD(dateFormat: String) -> String {
        let formater = DateFormatter()
        formater.calendar = .init(identifier: .gregorian)
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.dateFormat = dateFormat
        return formater.string(from: date)
            
    }

    
}
