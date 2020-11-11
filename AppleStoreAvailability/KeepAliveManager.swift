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
        mgr.distanceFilter = .greatestFiniteMagnitude
        mgr.desiredAccuracy = .greatestFiniteMagnitude
        mgr.allowsBackgroundLocationUpdates = true
        mgr.pausesLocationUpdatesAutomatically = false
        mgr.delegate = self
        return mgr
    }()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    @objc func didReceivedEnterForegroundNotification() {
        locationManager.stopUpdatingLocation()
    }
    
    @objc func didReceivedEnterBackgroundNotification() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestAuthorizationIfNeeded() {
        let authorizationStatus = locationManager.authorizationStatus
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
