//
//  CheckViewController.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class CheckViewController: UIViewController {

    private lazy var emptyLabel:UILabel = {
        let label = UILabel(frame: view.bounds)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "点击下方开始"
        return label
    }()
    
    private lazy var checkButton:UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: view.bounds.maxY - 200, width: view.bounds.width, height: 50))
        btn.setTitle("开始", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.red, for: .selected)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        btn.addTarget(self, action: #selector(startCheck), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Apple Store"
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(filter))
        view.addSubview(emptyLabel)
        
        view.addSubview(checkButton)
        
        KeepAliveManager.shared.requestAuthorizationIfNeeded()
    }
    
    @objc func filter() {
        navigationController?.pushViewController(FilterViewController(), animated: true)
    }
    
    @objc func startCheck() {
        checkButton.isSelected = !checkButton.isSelected
        
        if checkButton.isSelected {
            checkAvailability()
        }
    }
    
    @objc func checkAvailability() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://reserve-prime.apple.com/CN/zh_CN/reserve/A/availability.json")!) { (data, response, error) in
            if let err = error {
                print("\(err)")
            } else if let data = data {
                 
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    var response = AppleStoreAvailabilityResponse()
                    if let isToday = json["isToday"] as? Bool {
                        response.isToday = isToday
                    }
                    
                    if let updated = json["updated"] as? Int64 {
                        response.updated = updated
                    }
                    
                    if let storeList = json["stores"] as? [String:Any] {
                        
                        storeList.forEach { (storeNumber, storeValue) in
                            if let storeInfo = AppleStoreMapping[storeNumber] {
                                var store = AppleStore(storeNumber: storeNumber, info: storeInfo)
                                if let phoneList = storeValue as? [String:Any] {
                                    phoneList.forEach { (partNumber, phoneValue) in
                                        if let phoneInfo = iPhoneMapping[partNumber] {
                                            var phone = iPhone(partNumber: partNumber, info: phoneInfo)
                                            
                                            if let availabilityValue = phoneValue as? [String:Any], let availability = availabilityValue["availability"] as? [String: Any] {
                                                if let contract = availability["contract"] as? Bool {
                                                    phone.availability.contract = contract
                                                }
                                                
                                                if let unlocked = availability["unlocked"] as? Bool {
                                                    phone.availability.unlocked = unlocked
                                                }
                                            }
                                            store.iPhoneList.append(phone)
                                        }
                                    }
                                }
                                response.stores.append(store)
                            }
                        }
                    }
                    
                    // Filter
                    var hintText:String = ""
                    var availableList:[AppleStore] = []
                    for store in response.stores {
                        if !FilterManager.shared.filterList.contains(where: {$0.storeNumber == store.storeNumber}) {
                            continue
                        }
                        
                        let availablePhoneList = store.iPhoneList.filter({$0.availability.contract || $0.availability.unlocked})
                        if availablePhoneList.count > 0 {
                            var storeCopy = store
                            storeCopy.iPhoneList = availablePhoneList
                            availableList.append(storeCopy)
                            
                            hintText += "\(store.info.description)\n"
                            for phone in availablePhoneList {
                                hintText += "\(phone.info.description)\n"
                            }
                        }
                    }
                    
                    // Handle
                    if availableList.count > 0 {
                        print("----------------\n\(hintText)\n----------------")

                        DispatchQueue.main.async {
                            self.emptyLabel.font = UIFont.systemFont(ofSize: 24)
                            self.emptyLabel.text = hintText
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                    } else {
                        print("Availability checked: \(response.updated)")

                        DispatchQueue.main.async {
                            self.emptyLabel.font = UIFont.boldSystemFont(ofSize: 30)
                            self.emptyLabel.text = "暂时无货"
                        }
                    }
                }
            } else {
                print("Unknown error")
            }
            
            DispatchQueue.main.async {
                if self.checkButton.isSelected {
                    self.perform(#selector(self.checkAvailability), with: nil, afterDelay: 10)
                }
            }
        }
        
        task.resume()
    }
}
