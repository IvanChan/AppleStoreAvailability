//
//  StarManager.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/12.
//

import UIKit

class StarManager {
    static let shared = StarManager()

    private var starredStoreList:[AppleStore] = []
    private var starredProductList:[AppleProduct] = []

    private let key_starredStoreList = "ASA_starredStoreList"
    private let key_starredProductList = "ASA_starredProductList"

    init() {
        reloadFromDisk()
    }
    
    func reloadFromDisk() {
        reloadStoreFromDisk()
        reloadProductFromDisk()
    }
    
    func clearAll() {
        clearAllStarredStore()
        clearAllStarredProduct()
    }
}

extension StarManager {
    func reloadStoreFromDisk() {
        starredStoreList.removeAll()
        if let list = UserDefaults.standard.array(forKey: key_starredStoreList) as? [String] {
            for storeNumber in list {
                if let info = AppleStoreMapping[storeNumber] {
                    let store = AppleStore(with: storeNumber, info: info)
                    starredStoreList.append(store)
                }
            }
        }
    }
    
    func syncStoreToDisk() {
        let list = starredStoreList.compactMap({$0.storeNumber})
        UserDefaults.standard.setValue(list, forKey: key_starredStoreList)
    }
    
    func starredStoreCount() -> Int {
        return starredStoreList.count
    }
    
    func containStore(_ store:AppleStore) -> Bool {
        return starredStoreList.contains(where: {$0.storeNumber == store.storeNumber})
    }
    
    func starStore(_ store:AppleStore) {
        starredStoreList.insert(store, at: 0)
        syncStoreToDisk()
    }
    
    func removeStore(_ store:AppleStore) {
        starredStoreList.removeAll(where: {$0.storeNumber == store.storeNumber})
        syncStoreToDisk()
    }
    
    func clearAllStarredStore() {
        starredStoreList.removeAll()
        syncStoreToDisk()
    }
}

extension StarManager {
    func reloadProductFromDisk() {
        starredProductList.removeAll()
        if let list = UserDefaults.standard.array(forKey: key_starredProductList) as? [String] {
            for partNumber in list {
                if let info = AppleProductMapping[partNumber] {
                    let product = AppleProduct(with: partNumber, info: info)
                    starredProductList.append(product)
                }
            }
        }
    }
    
    func syncProductToDisk() {
        let list = starredProductList.compactMap({$0.partNumber})
        UserDefaults.standard.setValue(list, forKey: key_starredProductList)
    }
    
    func starredProductCount() -> Int {
        return starredProductList.count
    }
    
    func containProduct(_ product:AppleProduct) -> Bool {
        return starredProductList.contains(where: {$0.partNumber == product.partNumber})
    }
    
    func starProduct(_ product:AppleProduct) {
        starredProductList.insert(product, at: 0)
        syncProductToDisk()
    }
    
    func removeProduct(_ product:AppleProduct) {
        starredProductList.removeAll(where: {$0.partNumber == product.partNumber})
        syncProductToDisk()
    }
    
    func clearAllStarredProduct() {
        starredStoreList.removeAll()
        syncProductToDisk()
    }
}
