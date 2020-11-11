//
//  FilterViewController.swift
//  StoreAvailability
//
//  Created by _ivanC on 2020/11/11.
//

import UIKit

class FilterManager {
    static let shared = FilterManager()

    var filterList:[AppleStore] = []
    
    init() {
        reset()
    }
    
    func reset() {
        filterList.removeAll()
        AppleStoreMapping.forEach { (storeNumber, storeInfo) in
            let store = AppleStore(storeNumber: storeNumber, info: storeInfo)
            filterList.append(store)
        }
    }
}

class FilterViewController: UITableViewController {

    var dataArray:[[AppleStore]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "筛选店铺"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reset))
        // Do any additional setup after loading the view.
        var section:[String:[AppleStore]] = [:]
        AppleStoreMapping.forEach { (storeNumber, storeInfo) in
            let store = AppleStore(storeNumber: storeNumber, info: storeInfo)
            if var list = section[storeInfo.city] {
                list.append(store)
                section[storeInfo.city] = list
            } else {
                section[storeInfo.city] = [store]
            }
        }
        
        section.forEach { (key, value) in
            dataArray.append(value)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
    }
    
    @objc func reset() {
        FilterManager.shared.reset()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataArray[section].first?.info.city ?? "未知"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        let store = dataArray[indexPath.section][indexPath.row]
        cell.textLabel?.text = store.info.storeName
        
        if FilterManager.shared.filterList.contains(where: {$0.storeNumber == store.storeNumber}) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let store = dataArray[indexPath.section][indexPath.row]
        if FilterManager.shared.filterList.contains(where: {$0.storeNumber == store.storeNumber}) {
            FilterManager.shared.filterList.removeAll(where: {$0.storeNumber == store.storeNumber})
        } else {
            FilterManager.shared.filterList.append(store)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
