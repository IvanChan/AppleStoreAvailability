//
//  ViewController.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class ViewController: UIViewController {

    var myNavigationController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let navVC = UINavigationController(rootViewController: CheckViewController())
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        myNavigationController = navVC
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myNavigationController?.view.frame = view.bounds
    }
}

