//
//  ProductListViewController.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/12.
//

import UIKit

class ProductListViewController: UITableViewController {

    private var allProducts:[[AppleProduct]] = []
    private func reloadDataList() {
        allProducts.removeAll()
                
        var tempSection:[String:[AppleProduct]] = [:]
        AppleProductMapping.forEach { (partNumber, info) in
            let product = AppleProduct(with: partNumber, info: info)
            if var list = tempSection[info.name] {
                list.append(product)
                tempSection[info.name] = list
            } else {
                tempSection[info.name] = [product]
            }
        }
        
        tempSection.forEach { (key, value) in
            let list = value.sorted(by: { (p1, p2) -> Bool in
                if p1.info.color != p2.info.color {
                    return p1.info.color > p2.info.color
                }
                
                return p1.info.capacity > p2.info.capacity
            })
            allProducts.append(list)
        }
        
        allProducts.sort { (list1, list2) -> Bool in
            guard let first1 = list1.first else {
                return false
            }
            
            guard let first2 = list2.first else {
                return true
            }
            
            return first1.info.name > first2.info.name
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "产品列表"
    
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "reset"), style: .plain, target: self, action: #selector(clearAll))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StarCell")

        reloadDataList()
    }
    
    @objc func clearAll() {
        let alert = UIAlertController(title: "重置关心项", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            StarManager.shared.clearAllStarredProduct()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allProducts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProducts[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allProducts[section].first?.info.name ?? "未知"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StarCell", for: indexPath)
        
        let product = allProducts[indexPath.section][indexPath.row]
        cell.textLabel?.text = product.info.description
        
        if StarManager.shared.containProduct(product) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = allProducts[indexPath.section][indexPath.row]
        if StarManager.shared.containProduct(item) {
            StarManager.shared.removeProduct(item)
        } else {
            StarManager.shared.starProduct(item)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
