//
//  KeepAliveManager.swift
//  StoreAvailability
//
//  Created by _ivanc on 2020/11/11.
//

import UIKit
import CoreLocation

class KeepAliveManager : NSObject, CLLocationManagerDelegate {
    static let shared = KeepAliveManager()
    
    lazy var locationManager:CLLocationManager = {
        let mgr = CLLocationManager()
        mgr.activityType = .fitness
//        mgr.distanceFilter = .greatestFiniteMagnitude
//        mgr.desiredAccuracy = .greatestFiniteMagnitude
        mgr.allowsBackgroundLocationUpdates = true
        mgr.pausesLocationUpdatesAutomatically = false
        mgr.delegate = self
        return mgr
    }()
    
//    var count = 1
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)

//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
//            print("\(self.count)")
//            self.count += 1
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    @objc func didReceivedEnterForegroundNotification() {
        locationManager.stopUpdatingLocation()
    }
    
    private var bgTask:UIBackgroundTaskIdentifier?
    @objc func didReceivedEnterBackgroundNotification() {
        locationManager.startUpdatingLocation()
        bgTask = UIApplication.shared.beginBackgroundTask {
            if let bgTaskId = self.bgTask {
                UIApplication.shared.endBackgroundTask(bgTaskId)
                self.bgTask = nil
            }
        }
    }
    
    func requestAuthorizationIfNeeded() {
        let authorizationStatus = locationManager.authorizationStatus
        if authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        locationManager.stopUpdatingLocation()
    }
}
