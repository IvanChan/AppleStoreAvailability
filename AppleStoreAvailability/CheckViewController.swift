//
//  CheckViewController.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit
import AudioToolbox
import UserNotifications

class CheckViewController: UIViewController {

    private lazy var emptyLabel:UILabel = {
        let label = UILabel(frame: view.bounds)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var checkButton:UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: view.bounds.maxY - 200, width: view.bounds.width, height: 50))
        btn.setTitle("开始", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.gray, for: .selected)
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
        navigationController?.pushViewController(StarViewController(), animated: true)
    }
}

extension CheckViewController {
    @objc func startCheck() {
        checkButton.isSelected = !checkButton.isSelected
        
        if checkButton.isSelected {
            checkAvailability()
        }
    }
    
    func playWaitingAnimation() {
        stopWaitingAnnimation()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(value: 0)
        animation.toValue = NSNumber(value: 1)
        animation.autoreverses = true
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        checkButton.layer.add(animation, forKey: "LoadingAnimation")
    }
    
    func stopWaitingAnnimation() {
        checkButton.layer.removeAllAnimations()
    }
    
    func playStaredHittedAction(with availableList:[AppleStore]) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        AudioServicesPlaySystemSound(1021) //http://iphonedevwiki.net/index.php/AudioServices

        if UIApplication.shared.applicationState == .background {
            let content = UNMutableNotificationContent()

            var storeSet:Set<String> = []
            availableList.forEach({storeSet.insert($0.info.description)})
            var phoneSet:Set<String> = []
            availableList.forEach({$0.iPhoneList.forEach({phoneSet.insert($0.info.description)})})

            var title = storeSet.joined(separator: "/")
            if title.count <= 0 {
                title = "你关心的手机有现货"
            }
            
            var body = phoneSet.joined(separator: "/")
            if body.count <= 0 {
                body = "快来看看"
            }
            
            content.title = title
            content.body = body

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    @objc func checkAvailability() {
        stopWaitingAnnimation()
        
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
                    var hitStaredStore = false
                    var hintText:String = ""
                    var availableList:[AppleStore] = []
                    for store in response.stores {
                        
                        let availablePhoneList = store.iPhoneList.filter({$0.availability.contract || $0.availability.unlocked})
                        if availablePhoneList.count > 0 {
                            
                            if StarManager.shared.containStore(store) {
                                hitStaredStore = true
                            }
                            
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
                    DispatchQueue.main.async {

                        if availableList.count > 0 {
                            print("----------------\n\(hintText)\n----------------")
                            
                            self.emptyLabel.font = UIFont.systemFont(ofSize: 24)
                            self.emptyLabel.text = hintText
                            
                            if hitStaredStore {
                                self.view.backgroundColor = .red
                                self.playStaredHittedAction(with: availableList)
                            } else {
                                self.view.backgroundColor = .white
                            }
                        } else {
                            print("Availability checked: \(response.updated)")
                            
                            self.view.backgroundColor = .white
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
                    self.playWaitingAnimation()
                    self.perform(#selector(self.checkAvailability), with: nil, afterDelay: 10)
                }
            }
        }
        
        task.resume()
    }
}
