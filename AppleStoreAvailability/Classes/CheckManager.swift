//
//  CheckManager.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/12.
//

import UIKit

class CheckManager: NSObject {
    
    static let shared = CheckManager()
    
    private var checkingTask:[AppleStoreCheckingProduct] = AppleStoreCheckingProduct.allProduct
    private var isChecking = false
    private var checkingResult:[AppleStore] = []
    private func mergeResult(with result:[AppleStore]) {
        for store in result {
            if let existStore = checkingResult.first(where: {$0.storeNumber == store.storeNumber}) {
                existStore.productList += store.productList
            } else {
                checkingResult.append(store)
            }
        }
    }
    
    
    func startCheck(_ completion: @escaping ([AppleStore])->Void) {
        DispatchQueue.main.async {
            self._startCheck(completion)
        }
    }
    
    private func _startCheck(_ completion: @escaping ([AppleStore])->Void) {
        guard !isChecking else {
            return
        }
        
        isChecking = true
        checkingTask = AppleStoreCheckingProduct.allProduct
        checkingResult.removeAll()
        checkNext(completion)
    }
    
    private func checkNext(_ completion: @escaping ([AppleStore])->Void) {
        guard let task = checkingTask.first else {
            DispatchQueue.main.async {
                self.isChecking = false
                completion(self.checkingResult)
            }
            return
        }
        
        if !SettingsManager.checkingProductType.contains(task) {
            checkingTask.removeFirst()
            checkNext(completion)
            return
        }
        
        let url = task.requestURL
        checkingTask.removeFirst()
        if let requestUrl = url, requestUrl.absoluteString.count > 0 {
            check(with: requestUrl, completion)
        } else {
            checkNext(completion)
        }
    }
    
    private func check(with url:URL, _ completion: @escaping ([AppleStore])->Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("\(err)")
            } else if let data = data {
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    let response = AppleStoreAvailabilityResponse()
                    if let isToday = json["isToday"] as? Bool {
                        response.isToday = isToday
                    }
                    
                    if let updated = json["updated"] as? Int64 {
                        response.updated = updated
                    }
                    
                    if let storeList = json["stores"] as? [String:Any] {
                        
                        storeList.forEach { (storeNumber, storeValue) in
                            if let storeInfo = AppleStoreMapping[storeNumber] {
                                let store = AppleStore(with: storeNumber, info: storeInfo)
                                if let productList = storeValue as? [String:Any] {
                                    productList.forEach { (partNumber, productValue) in
                                        if let productInfo = AppleProductMapping[partNumber] {
                                            let product = AppleProduct(with: partNumber, info: productInfo)
                                            
                                            if let availabilityValue = productValue as? [String:Any], let availability = availabilityValue["availability"] as? [String: Any] {
                                                if let contract = availability["contract"] as? Bool {
                                                    product.availability.contract = contract
                                                }
                                                
                                                if let unlocked = availability["unlocked"] as? Bool {
                                                    product.availability.unlocked = unlocked
                                                }
                                            }
                                            store.productList.append(product)
                                        }
                                    }
                                }
                                response.stores.append(store)
                            }
                        }
                    }
                    
                    // Filter
                    var availableList:[AppleStore] = []
                    for store in response.stores {
                        let availableProductList = store.productList.filter({$0.availability.contract || $0.availability.unlocked})
                        if availableProductList.count > 0 {
                            store.productList = availableProductList
                            availableList.append(store)
                        }
                    }
                    
                    self.mergeResult(with: availableList)
                    self.checkNext(completion)
                }
            } else {
                print("Unknown error")
            }
        }
        task.resume()
    }
}
