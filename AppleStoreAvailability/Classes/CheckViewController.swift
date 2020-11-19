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

    private lazy var backgroundAnimatedView:UIView = {
        let bg = UIView(frame: view.bounds)
        bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bg.isUserInteractionEnabled = false
        bg.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        bg.isHidden = true
        return bg
    }()
    
    private lazy var displayTextView:UITextView = {
        let label = UITextView(frame: view.bounds)
        label.textAlignment = .center
        label.isEditable = false
        label.backgroundColor = .clear
        return label
    }()
    
    private var isCheckingEnabled = false
    private var isChecking = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Apple Store"

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startCheck))
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsClicked))

        view.backgroundColor = .white
        view.addSubview(backgroundAnimatedView)
        view.addSubview(displayTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedWillEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func settingsClicked() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    @objc func receivedWillEnterForegroundNotification() {
        if isCheckingEnabled {
            playCheckingAnnimation()
        } else {
            stopCheckingAnnimation()
        }
    }
}

extension CheckViewController {
    @objc func startCheck() {
        isCheckingEnabled = !isCheckingEnabled
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: isCheckingEnabled ? .pause : .play, target: self, action: #selector(startCheck))
        
        if isCheckingEnabled {
            playCheckingAnnimation()
        } else {
            stopCheckingAnnimation()
        }
        
        if !isChecking && isCheckingEnabled {
            checkAvailability()
        }
    }
    
    func playCheckingAnnimation() {
        stopCheckingAnnimation()
        backgroundAnimatedView.isHidden = false
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(value: 0)
        animation.toValue = NSNumber(value: 1)
        animation.autoreverses = true
        animation.duration = 1.6
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        backgroundAnimatedView.layer.add(animation, forKey: "LoadingAnimation")
    }
    
    func stopCheckingAnnimation() {
        backgroundAnimatedView.isHidden = true
        backgroundAnimatedView.layer.removeAllAnimations()
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
            var productSet:Set<String> = []
            availableList.forEach { (store) in
                if StarManager.shared.containStore(store) {
                    storeSet.insert(store.info.description)
                    store.productList.forEach { (product) in
                        if StarManager.shared.containProduct(product) {
                            productSet.insert(product.info.description)
                        }
                    }
                }
            }
            
            var title = storeSet.joined(separator: "/")
            if title.count <= 0 {
                title = "你关心的手机有现货"
            }
            
            var body = productSet.joined(separator: "/")
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

        isChecking = true
        CheckManager.shared.startCheck { (result) in
            
            if result.count > 0 {
                var shouldAlert = false
                let hintText = NSMutableAttributedString()

                let sortedResult = result.sorted { (s1, s2) -> Bool in
                    return StarManager.shared.containStore(s1)
                }
                
                for store in sortedResult {
                    
                    var hitstarredStore = false
                    var hitstarredProduct = false

                    var storeColor:UIColor = .darkGray
                    if StarManager.shared.containStore(store) {
                        hitstarredStore = true
                        storeColor = .red
                    }
                    
                    hintText.append(NSAttributedString(string: "\(store.info.description)\n", attributes: [.foregroundColor:storeColor, .font:UIFont.boldSystemFont(ofSize: 20)]))
                    
                    let sortedProductList = store.productList.sorted { (s1, s2) -> Bool in
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
                    
                    if !shouldAlert {
                        shouldAlert = hitstarredStore && hitstarredProduct
                    }
                }
                
                print("----------------\n\(hintText)\n----------------")
                self.displayTextView.attributedText = hintText
//                self.displayTextView.scrollRectToVisible(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), animated: false)
                self.isChecking = false
                if shouldAlert && self.isCheckingEnabled {
                    self.playstarredHittedAction(with: sortedResult)
                }
            } else {
                print("Availability checked: No available product")
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.alignment = .center
                paraStyle.lineBreakMode = .byWordWrapping
                self.displayTextView.attributedText = NSAttributedString(string: "\n\n\n暂时无货", attributes: [.foregroundColor:UIColor.darkGray, .font:UIFont.boldSystemFont(ofSize: 30), .paragraphStyle:paraStyle])
                
                self.isChecking = false
            }

            if self.isCheckingEnabled {
                self.perform(#selector(self.checkAvailability), with: nil, afterDelay: SettingsManager.refreshTimeInterval)
            }
        }
    }
}
