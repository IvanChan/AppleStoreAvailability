//
//  AppstoreProductMapping.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

struct AppleStoreCheckingProduct: OptionSet {
    let rawValue: Int
    
    static let iPhone12Pro = AppleStoreCheckingProduct(rawValue: 1 << 0)
    static let iPhone12 = AppleStoreCheckingProduct(rawValue: 1 << 1)
    static let iPhone12ProMax = AppleStoreCheckingProduct(rawValue: 1 << 2)
    static let iPhone12Mini = AppleStoreCheckingProduct(rawValue: 1 << 3)
    
    static let all: AppleStoreCheckingProduct = [.iPhone12Pro, .iPhone12, .iPhone12ProMax, .iPhone12Mini]
    static let allProduct: [AppleStoreCheckingProduct] = [.iPhone12Pro, .iPhone12, .iPhone12ProMax, .iPhone12Mini]
    
    var requestURL:URL? {
        var url:String?
        switch self {
        case .iPhone12Pro: url = "https://reserve-prime.apple.com/CN/zh_CN/reserve/A/availability.json"
        case .iPhone12: url = "https://reserve-prime.apple.com/CN/zh_CN/reserve/F/availability.json"
        case .iPhone12ProMax: url = "https://reserve-prime.apple.com/CN/zh_CN/reserve/G/availability.json"
        case .iPhone12Mini: url = "https://reserve-prime.apple.com/CN/zh_CN/reserve/H/availability.json"
        default: break
        }
        if let url = url {
            return URL(string:url)
        }
        return nil
    }
    
    var name:String {
        switch self {
        case .iPhone12Pro: return "iPhone 12 Pro"
        case .iPhone12: return "iPhone 12"
        case .iPhone12ProMax: return "iPhone 12 Pro Max"
        case .iPhone12Mini: return "iPhone 12 mini"
        default: return ""
        }
    }
}

let AppleProductMapping:[String:ProductInfo] = ["MGLD3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "128GB", color: "海蓝色"),
                                                "MGLH3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "256GB", color: "海蓝色"),
                                                "MGLM3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "512GB", color: "海蓝色"),
                                                
                                                "MGL93CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "128GB", color: "石墨色"),
                                                "MGLE3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "256GB", color: "石墨色"),
                                                "MGLJ3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "512GB", color: "石墨色"),
                                                
                                                "MGLC3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "128GB", color: "金色"),
                                                "MGLG3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "256GB", color: "金色"),
                                                "MGLL3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "512GB", color: "金色"),
                                                
                                                "MGLA3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "128GB", color: "银色"),
                                                "MGLF3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "256GB", color: "银色"),
                                                "MGLK3CH/A" : ProductInfo(name: "iPhone 12 Pro", capacity: "512GB", color: "银色"),
                                                
                                                
                                                
                                                "MGC33CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "128GB", color: "海蓝色"),
                                                "MGC73CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "256GB", color: "海蓝色"),
                                                "MGCE3CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "512GB", color: "海蓝色"),
                                                
                                                "MGC03CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "128GB", color: "石墨色"),
                                                "MGC43CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "256GB", color: "石墨色"),
                                                "MGC93CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "512GB", color: "石墨色"),
                                                
                                                "MGC23CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "128GB", color: "金色"),
                                                "MGC63CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "256GB", color: "金色"),
                                                "MGCC3CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "512GB", color: "金色"),
                                                
                                                "MGC13CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "128GB", color: "银色"),
                                                "MGC53CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "256GB", color: "银色"),
                                                "MGCA3CH/A" : ProductInfo(name: "iPhone 12 Pro Max", capacity: "512GB", color: "银色"),
                                                
                                                
                                                
                                                "MGGN3CH/A" : ProductInfo(name: "iPhone 12", capacity: "64GB", color: "白色"),
                                                "MGGV3CH/A" : ProductInfo(name: "iPhone 12", capacity: "128GB", color: "白色"),
                                                "MGH23CH/A" : ProductInfo(name: "iPhone 12", capacity: "256GB", color: "白色"),
                                                
                                                "MGGQ3CH/A" : ProductInfo(name: "iPhone 12", capacity: "64GB", color: "蓝色"),
                                                "MGGX3CH/A" : ProductInfo(name: "iPhone 12", capacity: "128GB", color: "蓝色"),
                                                "MGH43CH/A" : ProductInfo(name: "iPhone 12", capacity: "256GB", color: "蓝色"),
                                                
                                                "MGGT3CH/A" : ProductInfo(name: "iPhone 12", capacity: "64GB", color: "绿色"),
                                                "MGGY3CH/A" : ProductInfo(name: "iPhone 12", capacity: "128GB", color: "绿色"),
                                                "MGH53CH/A" : ProductInfo(name: "iPhone 12", capacity: "256GB", color: "绿色"),
                                                
                                                "MGGP3CH/A" : ProductInfo(name: "iPhone 12", capacity: "64GB", color: "红色"),
                                                "MGGW3CH/A" : ProductInfo(name: "iPhone 12", capacity: "128GB", color: "红色"),
                                                "MGH33CH/A" : ProductInfo(name: "iPhone 12", capacity: "256GB", color: "红色"),
                                                
                                                "MGGM3CH/A" : ProductInfo(name: "iPhone 12", capacity: "64GB", color: "黑色"),
                                                "MGGU3CH/A" : ProductInfo(name: "iPhone 12", capacity: "128GB", color: "黑色"),
                                                "MGH13CH/A" : ProductInfo(name: "iPhone 12", capacity: "256GB", color: "黑色"),
                                                
                                                
                                                
                                                "MG803CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "64GB", color: "白色"),
                                                "MG853CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "128GB", color: "白色"),
                                                "MG8A3CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "256GB", color: "白色"),
                                                
                                                "MG823CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "64GB", color: "蓝色"),
                                                "MG873CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "128GB", color: "蓝色"),
                                                "MG8D3CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "256GB", color: "蓝色"),
                                                
                                                "MG833CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "64GB", color: "绿色"),
                                                "MG883CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "128GB", color: "绿色"),
                                                "MG8E3CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "256GB", color: "绿色"),
                                                
                                                "MG813CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "64GB", color: "红色"),
                                                "MG863CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "128GB", color: "红色"),
                                                "MG8C3CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "256GB", color: "红色"),
                                                
                                                "MG7Y3CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "64GB", color: "黑色"),
                                                "MG843CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "128GB", color: "黑色"),
                                                "MG893CH/A" : ProductInfo(name: "iPhone 12 mini", capacity: "256GB", color: "黑色"),
                                                
]


//  https://reserve-prime.apple.com/CN/zh_CN/reserve/F/stores.json

let AppleStoreMapping:[String:StoreInfo] = ["R705" : StoreInfo(city: "上海", storeName: "七宝"),
                                            "R320" : StoreInfo(city: "北京", storeName: "三里屯"),
                                            "R401" : StoreInfo(city: "上海", storeName: "上海环贸 iapm"),
                                            "R534" : StoreInfo(city: "沈阳", storeName: "中街大悦城"),
                                            "R581" : StoreInfo(city: "上海", storeName: "五角场"),
                                            "R479" : StoreInfo(city: "北京", storeName: "华贸购物中心"),
                                            "R359" : StoreInfo(city: "上海", storeName: "南京东路"),
                                            "R493" : StoreInfo(city: "南京", storeName: "南京艾尚天地"),
                                            "R703" : StoreInfo(city: "南京", storeName: "南京金茂汇"),
                                            "R571" : StoreInfo(city: "南宁", storeName: "南宁万象城"),
                                            "R644" : StoreInfo(city: "厦门", storeName: "厦门新生活广场"),
                                            "R609" : StoreInfo(city: "大连", storeName: "大连恒隆广场"),
                                            "R531" : StoreInfo(city: "宁波", storeName: "天一广场"),
                                            "R638" : StoreInfo(city: "天津", storeName: "天津万象城"),
                                            "R637" : StoreInfo(city: "天津", storeName: "天津大悦城"),
                                            "R579" : StoreInfo(city: "天津", storeName: "天津恒隆广场"),
                                            "R577" : StoreInfo(city: "广州", storeName: "天环广场"),
                                            "R502" : StoreInfo(city: "成都", storeName: "成都万象城"),
                                            "R580" : StoreInfo(city: "成都", storeName: "成都太古里"),
                                            "R574" : StoreInfo(city: "无锡", storeName: "无锡恒隆广场"),
                                            "R670" : StoreInfo(city: "昆明", storeName: "昆明"),
                                            "R645" : StoreInfo(city: "北京", storeName: "朝阳大悦城"),
                                            "R532" : StoreInfo(city: "杭州", storeName: "杭州万象城"),
                                            "R576" : StoreInfo(city: "沈阳", storeName: "沈阳万象城"),
                                            "R646" : StoreInfo(city: "福州", storeName: "泰禾广场"),
                                            "R648" : StoreInfo(city: "济南", storeName: "济南恒隆广场"),
                                            "R389" : StoreInfo(city: "上海", storeName: "浦东"),
                                            "R484" : StoreInfo(city: "深圳", storeName: "深圳益田假日广场"),
                                            "R448" : StoreInfo(city: "北京", storeName: "王府井"),
                                            "R683" : StoreInfo(city: "上海", storeName: "环球港"),
                                            "R639" : StoreInfo(city: "广州", storeName: "珠江新城"),
                                            "R478" : StoreInfo(city: "大连", storeName: "百年城"),
                                            "R688" : StoreInfo(city: "苏州", storeName: "苏州"),
                                            "R643" : StoreInfo(city: "南京", storeName: "虹悦城"),
                                            "R388" : StoreInfo(city: "北京", storeName: "西单大悦城"),
                                            "R471" : StoreInfo(city: "杭州", storeName: "西湖"),
                                            "R480" : StoreInfo(city: "重庆", storeName: "解放碑"),
                                            "R572" : StoreInfo(city: "郑州", storeName: "郑州万象城"),
                                            "R573" : StoreInfo(city: "重庆", storeName: "重庆万象城"),
                                            "R476" : StoreInfo(city: "重庆", storeName: "重庆北城天街"),
                                            "R557" : StoreInfo(city: "青岛", storeName: "青岛万象城"),
                                            "R390" : StoreInfo(city: "上海", storeName: "香港广场")]

