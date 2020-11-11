//
//  AppleStoreAvailability.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

struct iPhoneAvailability {
    var contract:Bool = false
    var unlocked:Bool = false
}

struct iPhoneInfo {
    var name:String
    var color:String
    var capacity:String
    
    var description:String {
        return "\(name), \(color), \(capacity)"
    }
}

struct iPhone {
    var partNumber:String
    var info:iPhoneInfo
    
    var availability = iPhoneAvailability()
}

struct AppleStoreInfo {
    var city:String
    var storeName:String
//    var latitude:String
//    var longitude:String
    var enabled:Bool = false
    
    var description:String {
        return "\(city), \(storeName)"
    }
}

struct AppleStore {
    var storeNumber:String
    var info:AppleStoreInfo
    var iPhoneList:[iPhone] = []
}

struct AppleStoreAvailabilityResponse {
    var isToday:Bool = false
    var updated:Int64 = 0
    var launchDate: [String:Any]?
    var preLaunchStartDate: [String:Any]?
    var preLaunchStartTime: [String:Any]?

    var stores:[AppleStore] = []
}
