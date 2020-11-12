//
//  StoreListViewController.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class StoreListViewController: UITableViewController {

    private var allStores:[[AppleStore]] = []
    private func reloadAllStores() {
        allStores.removeAll()
                
        var tempSection:[String:[AppleStore]] = [:]
        AppleStoreMapping.forEach { (storeNumber, storeInfo) in
            let store = AppleStore(with: storeNumber, info: storeInfo)
            if var list = tempSection[storeInfo.city] {
                list.append(store)
                tempSection[storeInfo.city] = list
            } else {
                tempSection[storeInfo.city] = [store]
            }
        }
        
        tempSection.forEach { (key, value) in
            allStores.append(value)
        }
        
        allStores.sort { (list1, list2) -> Bool in
            guard let first1 = list1.first else {
                return false
            }
            
            guard let first2 = list2.first else {
                return true
            }
            
            return first1.info.city > first2.info.city
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "店铺列表"
    
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "reset"), style: .plain, target: self, action: #selector(clearAll))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StarCell")

        reloadAllStores()
    }
    
    @objc func clearAll() {
        let alert = UIAlertController(title: "重置关心项", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            StarManager.shared.clearAllStarredStore()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allStores.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStores[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allStores[section].first?.info.city ?? "未知"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StarCell", for: indexPath)
        
        let store = allStores[indexPath.section][indexPath.row]
        cell.textLabel?.text = store.info.storeName
        
        if StarManager.shared.containStore(store) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let store = allStores[indexPath.section][indexPath.row]
        if StarManager.shared.containStore(store) {
            StarManager.shared.removeStore(store)
        } else {
            StarManager.shared.starStore(store)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
