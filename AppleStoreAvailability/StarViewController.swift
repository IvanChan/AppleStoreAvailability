//
//  StarViewController.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class StarManager {
    static let shared = StarManager()

    private(set) var staredStoreList:[AppleStore] = []
    
    init() {
        reloadFromDisk()
    }
    
    func reloadFromDisk() {
        staredStoreList.removeAll()
        if let list = UserDefaults.standard.array(forKey: "ASA_staredStoreList") as? [String] {
            for storeNumber in list {
                if let info = AppleStoreMapping[storeNumber] {
                    let store = AppleStore(storeNumber: storeNumber, info: info)
                    staredStoreList.append(store)
                }
            }
        }
    }
    
    func containStore(_ store:AppleStore) -> Bool {
        return staredStoreList.contains(where: {$0.storeNumber == store.storeNumber})
    }
    
    func starStore(_ store:AppleStore) {
        staredStoreList.insert(store, at: 0)
        syncToDisk()
    }
    
    func removeStore(_ store:AppleStore) {
        staredStoreList.removeAll(where: {$0.storeNumber == store.storeNumber})
        syncToDisk()
    }
    
    func syncToDisk() {
        UserDefaults.standard.setValue(staredStoreList, forKey: "ASA_staredStoreList")
    }
    
    func clearAll() {
        staredStoreList.removeAll()
        syncToDisk()
    }
}


class StarViewController: UITableViewController {

    private var allStores:[[AppleStore]] = []
    private func reloadAllStores() {
        allStores.removeAll()
                
        var tempSection:[String:[AppleStore]] = [:]
        AppleStoreMapping.forEach { (storeNumber, storeInfo) in
            let store = AppleStore(storeNumber: storeNumber, info: storeInfo)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "特别关注"
    
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(clearAll))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StarCell")

        reloadAllStores()
    }
    
    @objc func clearAll() {
        StarManager.shared.clearAll()
        tableView.reloadData()
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
        
        if StarManager.shared.staredStoreList.contains(where: {$0.storeNumber == store.storeNumber}) {
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
