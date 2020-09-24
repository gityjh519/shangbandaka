//
//  MainContactView.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/9/7.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI

struct MainContactView: View {
    
    @EnvironmentObject var model: ContentItemJson
    
    @State private var isAddItem = false
    
    @State private var searchValue = ""
    
    @State private var isDelete = false
    @State private var message = ""
    
    @State var selectedModel: ContentItemJson?
    
    @State private var isSearch = false
    
    
    @State private var changeModel: ContentItemJson?
    
    
    
    var body: some View {
        NavigationView {
            List {
                SigleTextField(placeholder: "搜索指定会员", valueText: $searchValue, finished: .constant({ 
                    self.isSearch.toggle()
                })).frame(width: UIScreen.main.bounds.width - 60, height: 40, alignment: .center)
                listContent
                
            }.navigationBarTitle(Text(model.title), displayMode: .inline).navigationBarItems(leading: EditButton(),trailing: Button(action: {                 self.isAddItem.toggle()
                
            }, label: { 
                Text("+").font(Font.title)
            })).alert(isPresented: $isDelete) { () -> Alert in
                
                Alert(title: Text("提示"), message: Text(message), primaryButton: .cancel(), secondaryButton: .default(Text("确定"), action: { 
                    
                    self.model.contacts.removeAll { (subItem) -> Bool in
                        let b = subItem.id == self.selectedModel?.id
                        if b == true {
                            subItem.removeDataById()
                        }
                        return b
                    }
                    self.model.saveDataForKeys()
                }))
            }.onAppear { 
                self.changeSelectedModelData()
            }
            
        }.sheet(isPresented: $isAddItem) { () in
            AddPersonToList(superModel: self.model) { (json) in
                self.isAddItem.toggle()
                self.model.contacts.insert(json, at: 0)
                json.saveDataModel()
                self.model.saveDataForKeys()
            }
        }
    }
    
    var listContent: some View {
        
        ForEach(getCurrentList()) { (item: ContentItemJson)  in
            NavigationLink(destination: OtherContactView(model: item, isMainView: true, finishedBlock: { 
                self.changeModel = item

                
            })) {
                ContactItemCell(json: item)
            }
            
        }.onDelete { (set) in
            self.selectedModel = self.getCurrentList()[set.first!]
            self.message = "是否删除【\(self.selectedModel?.name ?? "")】名下的所有人员(\(self.selectedModel?.contacts.count ?? 0))"
            self.isDelete.toggle()
            
        }.onMove { (set, idx) in
            self.model.contacts.move(fromOffsets: set, toOffset: idx)
            self.model.saveDataForKeys()
        }.moveDisabled(!searchValue.isEmpty)
    }
    
    func changeSelectedModelData() {
        guard let item = changeModel else {
            return
        }
        let index = self.model.contacts.firstIndex { (subItem) -> Bool in
            subItem.id == item.id
        }
        if let idx = index {
            item.removeDataById()
            let tempModel = self.model.contacts[idx]
            let copyItem = tempModel.copyModel()
            copyItem.saveDataModel()
            self.model.contacts[idx] = copyItem
            self.model.saveDataForKeys()
        }
        self.changeModel = nil
    }
    
    
    func getCurrentList() -> [ContentItemJson] {
        if !searchValue.isEmpty {
            return model.searchItem(key: searchValue)
        }
        return model.contacts
    }
}




struct ContactItemCell: View {
    
    let json: ContentItemJson
    
    @State private var isDetial = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(json.name).onTapGesture {
                    self.isDetial.toggle()
                }.foregroundColor(Color(.link)).font(Font.system(size: 19)).padding(.bottom, 10)    
                
                Text(json.date).font(Font.system(size: 14)).foregroundColor(Color(UIColor.secondaryLabel))
            }.padding(.bottom, 10)
            
            Spacer()
            Text(getCurrentCount())
        }.sheet(isPresented: $isDetial) { () in
            
            PersonDetial(model: self.json) { 
                self.isDetial.toggle()
            }
        }
    }
    func getCurrentCount() -> String {
        json.contacts.count.description
    }
    
}

struct MainContactView_Previews: PreviewProvider {
    static var previews: some View {
        MainContactView().environmentObject(ContentItemJson(name: "我的", contacts: ContentItemJson.ceateList()))
        
    }
}


struct OtherContactView: View {
    @ObservedObject var model: ContentItemJson
    
    let isMainView: Bool
    
    @State var finishedBlock: (() -> Void)?
    
    @State private var selectedItem: ContentItemJson? = nil
    
    @State private var isAddItem = false
    
    @State private var searchValue = ""
    @State private var message = ""
    @State private var isDelete = false
    
    @State private var changeModel: ContentItemJson? = nil
    
    @EnvironmentObject var enviromentValue: ContentItemJson
    
    var body: some View {
        
        VStack {
            
            if isMainView {
                NavigationView {
                    
                    mainView
                }.navigationBarTitle("我的", displayMode: .inline)
            }else {
                mainView
            }
            
            
        }

    }
    
    var mainView: some View {
        List{
            cellView
            
        }.navigationBarTitle(Text(model.title), displayMode: .inline).sheet(isPresented: $isAddItem) { ()  in
            AddPersonToList(superModel: self.model) { (item) in
                self.addItemToList(item: item)
            }
        }.navigationBarItems(trailing: Button(action: { 
            self.isAddItem.toggle()
        }, label: { 
            Text("+").font(Font.title)
        })).onAppear { 
            self.changeCurrentModel()
        }
    }
    
    var cellView: some View {
        
        ForEach(model.contacts) { (item: ContentItemJson) in
            NavigationLink(destination: OtherContactView(model: item, isMainView: false,finishedBlock: {
                self.changeModel = item
            })) {
                ContactItemCell(json: item)
            }
        }.onDelete { (set) in
            let index = set.first!
            let cModel = self.model.contacts[index]
            self.message = "是否删除【\(cModel.name)】名下的所有人员(\(cModel.contacts.count))"
            self.selectedItem = cModel
            self.isDelete.toggle()
            
        }.alert(isPresented: $isDelete) { () -> Alert in
            Alert(title: Text("提示"), message: Text(self.message), primaryButton: .cancel(), secondaryButton: .default(Text("确定"), action: { 
                self.model.contacts.removeAll { (subItem) -> Bool in
                    subItem.id == self.selectedItem?.id
                }
                self.isDelete.toggle()
                self.finishedBlock?()
            }))
        }
    }
    
    func addItemToList(item: ContentItemJson) {
//        self.isAddItem.toggle()
        
//        let index = enviromentValue.contacts.firstIndex { (subItem) -> Bool in
//            subItem.id == self.model.id
//        }
//        guard let idx = index else {
//            return;
//        }
//        model.contacts.insert(item, at: 0)
//        let copyItem = model.copyModel();
//        enviromentValue.contacts[idx] = copyItem
        self.isAddItem.toggle()
        self.model.contacts.insert(item, at: 0)
        
        self.finishedBlock?()
    }
    
    
    func changeCurrentModel() {
        
        guard let item = changeModel else {
            return
        }
        
        let index = self.model.contacts.firstIndex { (subItem) -> Bool in
            subItem.id == item.id
        }
        if let idx = index {
            let tempModel = self.model.contacts[idx]
            self.model.contacts[idx] = tempModel.copyModel()
        }
        self.finishedBlock?()

        changeModel = nil
    }
    
}


struct AddPersonToList: View {
    let superModel: ContentItemJson
    var finishedBlock: ((_ name: ContentItemJson)-> Void)
    @State private var name = ""
    
    @State private var remark = ""
    @State private var isEdit = false
    
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("在【\(superModel.name)】下，添加一个新会员").padding()
                SigleTextField(placeholder: "请输入名字(必填)", valueText: $name, finished: .constant({ 
                    
                })).frame(width: 340, height: 40, alignment: .center).textFieldStyle(RoundedBorderTextFieldStyle()).alert(isPresented: self.$showAlert) { () -> Alert in
                    Alert(title: Text("提示"), message: Text("请输入姓名"), dismissButton: nil)
                }
                
                Text("添加备注")
                TextView(defalutText: "", valueText: self.$remark, isCanEdit: self.$isEdit, finishedBlock: .constant({ 
                    
                })).frame(width: UIScreen.main.bounds.width - 40, height: 200, alignment: .center).border(Color(UIColor.lightGray), width: 1).shadow(radius: 2)
                
                Spacer()
                
            }.navigationBarTitle(Text(superModel.name), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                if !self.name.isEmpty {
                    let currentModel = ContentItemJson(name: self.name, contacts: [ContentItemJson]())
                    if self.superModel.relation.isEmpty {
                        currentModel.relation = self.superModel.name
                    }else {
                        currentModel.relation = self.superModel.relation + ">" + self.superModel.name
                    }
                    if !self.remark.isEmpty {
                        currentModel.saveCurrentRemark(remark: self.remark)
                    }
                    self.finishedBlock(currentModel)
                }else {
                    self.showAlert.toggle()

                }
            }, label: { 
                Text("确定")
            }))
        }
    }
}

struct PersonDetial: View {
    let model: ContentItemJson
    let finishedBlock: (() -> Void)?
    
    
    @State private var textValue = ""
    
    @State private var isCanEdit = false
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center) {
                
                Text(self.relationText()).lineLimit(100).multilineTextAlignment(.center).padding()
                
                
                GeometryReader { (geo: GeometryProxy) in
                    
                    TextView(defalutText: self.model.readRemark(), valueText: self.$textValue, isCanEdit: self.$isCanEdit, finishedBlock: .constant(nil)).frame(width: geo.size.width - 20, height: geo.size.height - 60, alignment: .leading).border(Color(UIColor.lightGray), width: 1).shadow(radius: 2).offset(x: 0, y: -40)
                    
                }.navigationBarTitle(Text("\(model.name)"), displayMode: .inline).navigationBarItems(trailing: Button(action: { 
                    self.isCanEdit.toggle()
                    self.model.saveCurrentRemark(remark: self.textValue)
                    self.finishedBlock?()
                    
                    
                }, label: { 
                    Text("完成")
            }))
                Spacer()
            }
            
        }
    }
    
    private func relationText() -> String {
        var text = "继承关系图：\n"
        if !self.model.relation.isEmpty {
            text += model.relation
        }else {
            text += "我的"
        }
        return text
    }
    
   
}
