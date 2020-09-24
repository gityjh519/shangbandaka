
//
//  ContactJson.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/9/7.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI


class ContentItemJson: NSObject, Codable,Identifiable,ObservableObject {
    let id: String
    let name: String
    let date: String
    var relation: String

    
    var title: String {
        name + "(\(contacts.count))"
    }
    
    @Published var contacts: [ContentItemJson]
    
    
    enum JsonKey: String, CodingKey {
        case id
        case name
        case contacts
        case date
        case relation
    }
    
    init(name: String,contacts: [ContentItemJson]) {
        self.name = name;
        self.contacts = contacts;
        let dateFormater = DateFormatter();
        dateFormater.locale = Locale(identifier: "zh-Hans_US")
        dateFormater.dateFormat = "yyyyMMddHHmmssSSS";
        dateFormater.calendar = .init(identifier: .gregorian)
        self.id = dateFormater.string(from: Date())
        dateFormater.dateFormat = "yyyy年MM月dd日 EEEE HH:mm"
        self.date = dateFormater.string(from: Date())
        
        relation = ""
    }
    
    required init(from decoder: Decoder) throws {
        let value = try? decoder.container(keyedBy: JsonKey.self)
        if let idValue = try? value?.decode(String.self, forKey: .id) {
            self.id = idValue 
        }else {
            self.id = ""
        }
        let nameValue = try? value?.decode(String.self, forKey: .name);
        self.name = nameValue ?? "";
        self.contacts = (try? value?.decode([ContentItemJson].self, forKey: .contacts)) ?? [ContentItemJson]()
        
        self.date = (try? value?.decode(String.self, forKey: .date)) ?? ""
        
        relation = (try? value?.decode(String.self, forKey: .relation)) ?? ""


    }
    func encode(to encoder: Encoder) throws {
        var data = encoder.container(keyedBy: JsonKey.self);
        try? data.encode(name, forKey: .name)
        try? data.encode(id, forKey: .id)
        try? data.encode(contacts, forKey: .contacts)
        try? data.encode(date, forKey: .date)
        try? data.encode(relation, forKey: .relation)


    }
    func copyModel() -> ContentItemJson {
        let model = ContentItemJson(name: name, contacts: contacts);
        model.relation = relation;
        return model;
    }
    
    override var description: String {
       "[" + id + "]" + name + "[" + contacts.description  + "]"
    }
}


extension ContentItemJson {
    class func ceateList() -> [ContentItemJson] {

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/";
        let keyPath = path + "key";
        let json = JSONDecoder();
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: keyPath)) else{
            return [ContentItemJson]()
        }
        
        guard let keys = try? json.decode([String].self, from: data) else{
            return [ContentItemJson]()
        }
        DataBaseManger.saveDataForKey(keys: keys);
        var allListModel = [ContentItemJson]()
        for key in keys {
            let rootPath = path + key;
            if let modelData = try? Data(contentsOf: URL(fileURLWithPath: rootPath)) {
                if let model = try? json.decode(ContentItemJson.self, from: modelData) {
                    allListModel.append(model)
                    DataBaseManger.saveDataModel(item: model);
                }
            }
            
        }
        return allListModel
    }
    
   
    
    func saveCurrentRemark(remark: String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/remark/";
        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        try? remark.write(to: URL(fileURLWithPath: path + id), atomically: true, encoding: .utf8)
    }
    func readRemark() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/remark/";
        let value = try? String(contentsOf: URL(fileURLWithPath: path + id))
        return value ?? ""
    }
   
}
// 新的方法 只保存key 
extension ContentItemJson {
    
    func saveDataModel() -> Void {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/";
//        let file = FileManager.default;
//        if !file.fileExists(atPath: path) {
//            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        }
//        let rootPath = path + id;
//        let json = JSONEncoder();
//        let data = try? json.encode(self);
//        try? data?.write(to: URL(fileURLWithPath: rootPath))
        
        DataBaseManger.saveDataModel(item: self)
        
    }
    
    func saveDataForKeys() {
//         let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/";
//         let file = FileManager.default;
//         if !file.fileExists(atPath: path) {
//             try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//         }
         
         let ids = contacts.map { $0.id }
        DataBaseManger.saveDataForKey(keys: ids)
        
//         let json = JSONEncoder();
//         if let value = try? json.encode(ids) {
//             try? value.write(to: URL(fileURLWithPath: path + "key"));
//         }
     }
    
    func removeDataById() {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/";
//        let rootPath = path + id;
//        let file = FileManager.default;
//        try? file.removeItem(atPath: rootPath)
        
        DataBaseManger.removeDataItem(id: id)

    }
}


extension ContentItemJson {
    func searchItem(key: String) -> [ContentItemJson] {
        
        var allList = [ContentItemJson]()
        for item in contacts {
            
            if item.name.contains(key) {
                allList.append(item);
            }
            let list = item.searchItem(key: key);
            if list.count > 0 {
                allList.append(contentsOf: list);
            }
        }
        return allList;
    }
    
    func selectedFitKey(key: String,list: [ContentItemJson]) -> [ContentItemJson] {
        list.filter { (item) -> Bool in
            item.name.contains(key)
        }
    }
}


class DataBaseManger: NSObject {
    
//    fileprivate static let shareInstance = DataBaseManger()
    fileprivate static var dataDict = [String: ContentItemJson]();
    fileprivate static var dataForKey = [String]()
    
    fileprivate static var changeKeyId = [String]()
    
//    static var changeSorted = false
    
    private override init() {
        super.init()
    }
    
    class func saveDataModel(item: ContentItemJson) {
        dataDict[item.id] = item;
        changeKeyId.append(item.id)
    }
    class func saveDataForKey(keys: [String]) -> Void {
        dataForKey = keys
    }
    
    class func removeDataItem(id: String) {
        dataDict.removeValue(forKey: id)
        changeKeyId.append(id)

    }
    
    class func saveToFileData() {
        
        
        if changeKeyId.isEmpty  {
            return;
        }
     
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/userData/";
        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        

        let rootPath = path + "key";
        let json = JSONEncoder();
        let keyData = try? json.encode(dataForKey);
        try? keyData?.write(to: URL(fileURLWithPath: rootPath))
        
        for item in dataDict {
            if changeKeyId.contains(item.key) {
                let dataPath = path + item.key;
                let data = try? json.encode(item.value)
                try? data?.write(to: URL(fileURLWithPath: dataPath))
            }else {
                print("不需要修改的文件》\(item.key)" + item.value.name + item.value.contacts.description);
            }
        }
        changeKeyId.removeAll()

    }
}
