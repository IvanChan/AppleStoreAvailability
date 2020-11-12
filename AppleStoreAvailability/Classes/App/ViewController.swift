//
//  ViewController.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class ViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let productListVC = UINavigationController(rootViewController:ProductListViewController())
        productListVC.tabBarItem.title = "Product"
        productListVC.tabBarItem.image = UIImage(named: "product")
        
        let checkVC = UINavigationController(rootViewController: CheckViewController())
        checkVC.tabBarItem.title = "Home"
        checkVC.tabBarItem.image = UIImage(named: "home")

        let storeListVC = UINavigationController(rootViewController:StoreListViewController())
        storeListVC.tabBarItem.title = "Store"
        storeListVC.tabBarItem.image = UIImage(named: "store")
        
        viewControllers = [productListVC, checkVC, storeListVC]
        selectedIndex = 1
        
        KeepAliveManager.shared.requestAuthorizationIfNeeded()

    }
}

