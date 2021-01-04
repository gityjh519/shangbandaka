//
//  DateModel.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/8/18.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI
import Combine



class DateItemModel: ObservableObject,Identifiable {
    var id = 99
    
    var isSaveData = true;
    
    @Published var list = DateModel.readDateFromDiskFor(date:DateModel.currentDate) {
        didSet{
            if isSaveData {
                saveData()
            }
        }
    }
    
    @Published var yyyyMM = DateModel.currentDate {
        didSet{
            isSaveData = false
            list = DateModel.readDateFromDiskFor(date: yyyyMM)
            isSaveData = true
        }
    }
    
 
    
    var currentDate: String {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy年MM月dd日 EEEE";
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.calendar = .init(identifier: .gregorian);
        return formater.string(from: Date());
    }
    

    
    func saveData() {
        saveDataByDate()
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data";
//
//        let file = FileManager.default;
//        if !file.fileExists(atPath: path) {
//            file.createFile(atPath: path, contents: nil, attributes: nil);
//        }
//        let json = JSONEncoder();
//        let data = try? json.encode(list);
//        try? data?.write(to: URL(fileURLWithPath: path))
        
    }
  
    func saveDataByDate() {
        
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/date/"

        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        path = path + yyyyMM
        
        let json = JSONEncoder();
        let data = try? json.encode(list);
        try? data?.write(to: URL(fileURLWithPath: path))
        
    }
    
    
}

struct DateModel: Codable,Identifiable {
    let id: String
    var beginTime: String?
    var endTime: String?
    var date: String?
    var isCaculateTime: Bool?
    
//    var externTimeInt: Int {
//        
//        if isCaculateTime != nil {
//            if isCaculateTime != true {
//                return 0;
//            }
//        }
//        
//        
//        guard let eTime = endTime  else {
//            return 0;
//        }
//        let endTimeSegment = eTime.components(separatedBy: ":");
//        if endTimeSegment.count != 3 {
//            return 0;
//        }
//        
//        let bTime = beginTime!.components(separatedBy: ":")
//        var bHH = 19;
//        var externHHHH = 0;
//        if ["星期六","星期日"].contains(where: { (item) -> Bool in
//            dateWeek!.contains(item)
//        }) {
//         
//            bHH = Int(bTime[0])!
//            let bm = Int(bTime[1])!
//            if bm <= 30 {
//                externHHHH = 1;
//            }else {
//                bHH += 1
//            }
//        }
//        
////        let endHour = Int(endTimeSegment[0])
//        
//        
//        let hh = Int(endTimeSegment[0])! - bHH;
//        
//        if hh < 0 {
//            return 0;
//        }
//        let mm = Int(endTimeSegment[1])!
//        let extenHH = (hh * 60 + mm) / 30 + externHHHH
//        return extenHH;
//    }
    
    var externTimeInt: Int {
        
        if isCaculateTime != nil {
            if isCaculateTime != true {
                return 0;
            }
        }
        
        
        guard let eTime = endTime ,beginTime != nil  else {
            return 0;
        }
        let endTimeSegment = eTime.components(separatedBy: ":");
        if endTimeSegment.count != 3 {
            return 0;
        }
        
        let bTime = beginTime!.components(separatedBy: ":")
        var beginHour = 19;
        var externHHHH = 0;
        if ["星期六","星期日"].contains(where: { (item) -> Bool in
            dateWeek!.contains(item)
        }) {
         
            beginHour = Int(bTime[0])!
            let bm = Int(bTime[1])!
            if bm <= 30 {
                externHHHH = 1;
            }else {
                beginHour += 1
            }
        }
        
        let endHour = Int(endTimeSegment[0])!
        
        if endHour < beginHour  {
            
            if endHour > 6 {
                return 0
            }
            
            var hh = (24 - beginHour + endHour) * 2;
            let endMin = Int(endTimeSegment[1])!
            if endMin > 30 {
                hh += 1
            }
            return hh
            
        }else {
            let hh = Int(endTimeSegment[0])! - beginHour;
     
            let mm = Int(endTimeSegment[1])!
            let extenHH = (hh * 60 + mm) / 30 + externHHHH
            return extenHH;
        }
        
        
    }
    
//    var externTimeInt: Int {
//        
//        if isCaculateTime != nil {
//            if isCaculateTime != true {
//                return 0;
//            }
//        }
//        
//        if beginTime == nil || endTime == nil {
//            return 0
//        }
//        
//        let beginDate = date! + " " + beginTime!;
//        let endDate = date! + " " + endTime!;
//        
//        let formater = DateFormatter()
//        formater.dateFormat = "yyyy年MM月dd日 EEEE HH:mm:ss";
//        formater.locale = Locale(identifier: "zh-Hans_US")
//        formater.calendar = .init(identifier: .gregorian);
//        
//        let bTimes = formater.date(from: beginDate);
//        let dTimes = formater.date(from: endDate);
//        
//        let otherTimes = dTimes?.timeIntervalSince(bTimes!) ?? 0
//        let extenT = ["星期六","星期日"].contains { (item) -> Bool in
//            dateWeek!.contains(item)
//        } 
//        return Int((otherTimes / 60.0 / 60.0) / 30.0 - (extenT ? 0 : 10.5) )
//        
//    }
    
    func saveCurrentRemark(remark: String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/date/remark/";
        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        try? remark.write(to: URL(fileURLWithPath: path + dateWeek!), atomically: true, encoding: .utf8)
    }
    func readRemark() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/date/remark/";
        let value = try? String(contentsOf: URL(fileURLWithPath: path + dateWeek!))
        return value ?? ""
    }
    
    
    var externTime: String? {
        
        let extenHH = externTimeInt
        if extenHH <= 0 {
            return nil;
        }
        return "加班时长：" + String(format: "%0.1f", Double(extenHH) / 2.0) + "个小时";
    }
    
    var color: Color {

        if dateWeek?.contains("星期日") == true || dateWeek?.contains("星期六") == true {
            return Color.init(red: 219.0/255.0, green: 80.0/255.0, blue: 72.0/255.0)
        }
        return Color.init(red: 35.0/255.0, green: 160.0/255.0, blue: 96.0/255.0)
    }
    
    var yyyyMM: String {
        String(dateWeek![..<dateWeek!.index(dateWeek!.startIndex, offsetBy: 8)])
    }
    
    var dateWeek: String? {
        
        guard let dateItem = date else{
            return nil;
        }
        if dateItem.contains("星期") && dateItem.contains("年") {
            return dateItem;
        }
        let formater = DateFormatter();
        formater.dateFormat = "yyyy年MM月dd日"
        formater.calendar = .init(identifier: .gregorian);
        formater.locale = Locale(identifier: "zh-Hans_US");

        let fullDate = "2020年" + dateItem;
        if let valueDate = formater.date(from: fullDate) {
            
            formater.dateFormat = "yyyy年MM月dd日 EEEE"

            let stringValue = formater.string(from: valueDate)
            return stringValue
        }
        return dateItem
        
    }
        
    
    var beginTimeValue: String {
        if let time = beginTime {
            return "上班：" + time
        }
        return "未打卡"
    }
    var endTimeValue: String {
        if let time = endTime {
            return "下班：" + time
        }
        return "未打卡"
    }
    
    init(beginTime: String?,endTime: String?,date: String?) {
        self.beginTime = beginTime;
        self.endTime = endTime;
        self.date = date;
        let dateFormater = DateFormatter();
        dateFormater.dateFormat = "yyyyMMddHHmmssSSS";
        dateFormater.calendar = .init(identifier: .gregorian)
        self.id = dateFormater.string(from: Date())
        self.isCaculateTime = true
    }
    
   
    
    var currentTime: String {
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm:ss";
        formater.calendar = .init(identifier: .gregorian);
        return formater.string(from: Date())
    }
    
}

extension DateModel {
    static func readDateFromDiskFor(date: String) -> [DateModel] {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/date/" + date;
        
        print("-->\(path)")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else{
            return [DateModel]()
        } 
        let json = JSONDecoder();
        let list = try? json.decode([DateModel].self, from: data);
        if let otherList = list {
           let newList = otherList.sorted { (a, b) -> Bool in
            
                a.dateWeek?.compare(b.dateWeek ?? "") == ComparisonResult.orderedDescending
            }
            
            return newList
        }
        return list ?? [DateModel]()
    }
    
    static var currentDate: String {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy年MM月";
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.calendar = .init(identifier: .gregorian);
        return formater.string(from: Date());
    }
    
}

extension DateModel {
    static func readDataFromDisk() -> [DateModel] {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data";
        
       
        
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else{
            return [DateModel]()
        }
        let json = JSONDecoder();
        let list = try? json.decode([DateModel].self, from: data);
        if let otherList = list {
           let newList = otherList.sorted { (a, b) -> Bool in
            
                a.dateWeek?.compare(b.dateWeek ?? "") == ComparisonResult.orderedDescending
            }
            
            return newList
        }
        return list ?? [DateModel]()
    }
    
    
}


extension DateModel {
    static var ymList: [Int] {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM"
        formater.locale = Locale(identifier: "zh-Hans_US")
        formater.calendar = .init(identifier: .gregorian)
        let value = formater.string(from: Date())
        let list = value.components(separatedBy: "-")
        let yIdx = Int(list[0])! - 2020
        let mIdx = Int(list[1])!
        return [yIdx,mIdx]
    }
}

extension DateItemModel {
    
   class func readAllDateItems() -> [DateModel] {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/date";
        let file = FileManager.default;
    

    guard var directoryList = file.enumerator(atPath: path)?.allObjects as? [String] else {
        return [DateModel]()
    }
    
    var allList = [DateModel]()
      
    directoryList.removeAll { (item) -> Bool in
         !item.contains("年")
    }
    
    for item in directoryList {
        let items = DateModel.readDateFromDiskFor(date: item)
        allList.append(contentsOf: items);
    }
    
        return allList
    }
}
