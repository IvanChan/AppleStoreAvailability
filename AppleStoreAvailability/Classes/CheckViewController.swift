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

    private lazy var displayTextView:UITextView = {
        let label = UITextView(frame: view.bounds)
        label.textAlignment = .center
        label.isEditable = false
        return label
    }()
    
    private lazy var checkButton:UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: view.bounds.maxY - 200, width: view.bounds.width, height: 50))
        btn.setTitle("开始", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.setTitleColor(.gray, for: .selected)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        btn.addTarget(self, action: #selector(startCheck), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Apple Store"

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsClicked))

        view.backgroundColor = .white
        view.addSubview(displayTextView)
        view.addSubview(checkButton)        
    }
    
    @objc func settingsClicked() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
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
    
    func playstarredHittedAction(with availableList:[AppleStore]) {
        if SettingsManager.checkingAlertType.contains(.vibrate) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        
        if SettingsManager.checkingAlertType.contains(.sound) {
            AudioServicesPlaySystemSound(1021) //http://iphonedevwiki.net/index.php/AudioServices
        }
        
        if SettingsManager.checkingAlertType.contains(.animation) {

        }
        
        if SettingsManager.checkingAlertType.contains(.backgroundNotification), UIApplication.shared.applicationState == .background {
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

        CheckManager.shared.startCheck { (result) in
            
            if result.count > 0 {
                var hitstarredStore = false
                var hitstarredProduct = true

                let hintText = NSMutableAttributedString()

                let sortedResult = result.sorted { (s1, s2) -> Bool in
                    return StarManager.shared.containStore(s1)
                }
                
                for store in sortedResult {
                    
                    var storeColor:UIColor = .darkGray
                    if StarManager.shared.containStore(store) {
                        hitstarredStore = true
                        storeColor = .red
                    }
                    
                    if StarManager.shared.starredProductCount() > 0 {
                        hitstarredProduct = false
                    }
                    
                    hintText.append(NSAttributedString(string: "\(store.info.description)\n", attributes: [.foregroundColor:storeColor, .font:UIFont.boldSystemFont(ofSize: 20)]))
                    
                    let sortedProductList = store.iPhoneList.sorted { (s1, s2) -> Bool in
                        return StarManager.shared.containProduct(s1)
                    }
                    
                    for product in sortedProductList {
                        var productColor:UIColor = .gray
                        if StarManager.shared.containProduct(product) {
                            productColor = UIColor.red.withAlphaComponent(0.6)
                            hitstarredProduct = true
                        }

                        hintText.append(NSAttributedString(string: " \(product.info.description)\n", attributes: [.foregroundColor:productColor, .font:UIFont.systemFont(ofSize: 20)]))
                    }
                    
                    hintText.append(NSAttributedString(string: "\n", attributes: [.foregroundColor:storeColor, .font:UIFont.boldSystemFont(ofSize: 20)]))
                }
                
                print("----------------\n\(hintText)\n----------------")
                self.displayTextView.attributedText = hintText
                
                if hitstarredStore && hitstarredProduct {
                    self.playstarredHittedAction(with: result)
                }
            } else {
                print("Availability checked: No available product")
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.alignment = .center
                paraStyle.lineBreakMode = .byWordWrapping
                self.displayTextView.attributedText = NSAttributedString(string: "\n\n\n暂时无货", attributes: [.foregroundColor:UIColor.darkGray, .font:UIFont.boldSystemFont(ofSize: 30), .paragraphStyle:paraStyle])
            }

            if self.checkButton.isSelected {
                self.playWaitingAnimation()
                self.perform(#selector(self.checkAvailability), with: nil, afterDelay: SettingsManager.refreshTimeInterval)
            }
        }
    }
}
