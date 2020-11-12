//
//  AppleStoreAvailability.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class ProductAvailability {
    var contract:Bool = false
    var unlocked:Bool = false
}

class ProductInfo {
    var name:String
    var capacity:String
    var color:String

    var description:String {
        return "\(name) \(capacity) \(color)"
    }
    
    init(name:String, capacity:String, color:String) {
        self.name = name
        self.capacity = capacity
        self.color = color
    }
}

class AppleProduct {
    var partNumber:String
    var info:ProductInfo
    
    var availability = ProductAvailability()
    
    init(with partNumber:String, info:ProductInfo) {
        self.partNumber = partNumber
        self.info = info
    }
}

class StoreInfo {
    var city:String
    var storeName:String
//    var latitude:String
//    var longitude:String
    var enabled:Bool = false
    
    var description:String {
        return "\(city), \(storeName)"
    }
    
    init(city:String, storeName:String) {
        self.city = city
        self.storeName = storeName
    }
}

class AppleStore {
    var storeNumber:String
    var info:StoreInfo
    var iPhoneList:[AppleProduct] = []
    
    init(with storeNumber:String, info:StoreInfo) {
        self.storeNumber = storeNumber
        self.info = info
    }
}

class AppleStoreAvailabilityResponse {
    var isToday:Bool = false
    var updated:Int64 = 0
    var launchDate: [String:Any]?
    var preLaunchStartDate: [String:Any]?
    var preLaunchStartTime: [String:Any]?

    var stores:[AppleStore] = []
}


extension AppleStore {
    func mergedPhoneDescription() ->String {
        var tempDescMap:[String:[AppleProduct]] = [:]
        for phone in iPhoneList {
            if var list = tempDescMap[phone.info.name] {
                list.append(phone)
                tempDescMap[phone.info.name] = list
            } else {
                tempDescMap[phone.info.name] = [phone]
            }
        }
        
        var descList:[String] = []
        tempDescMap.forEach { (name, phoneList) in
            var desc = "\(name) "
            for i in 0..<phoneList.count {
                let phone = phoneList[i]
                desc += "\(phone.info.color)\(phone.info.capacity)"
                if i != phoneList.count-1 {
                    desc += "/"
                }
            }
            descList.append(desc)
        }
        return descList.joined(separator: ", ")
    }
}
