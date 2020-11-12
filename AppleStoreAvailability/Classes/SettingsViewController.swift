//
//  SettingsViewController.swift
//  AppleStoreAvailability
//
//  Created by _ivanC on 2020/11/12.
//

import UIKit

struct CheckingAlertType: OptionSet {
    let rawValue: Int
    
    static let animation = CheckingAlertType(rawValue: 1 << 0)
    static let sound = CheckingAlertType(rawValue: 1 << 1)
    static let backgroundNotification = CheckingAlertType(rawValue: 1 << 2)
    static let vibrate = CheckingAlertType(rawValue: 1 << 3)

    static let all: CheckingAlertType = [.animation, .sound, .backgroundNotification, .vibrate]
    static let allType: [CheckingAlertType] = [.animation, .sound, .backgroundNotification, .vibrate]
    
    var name:String {
        switch self {
        case .animation: return "动画"
        case .sound: return "声音"
        case .backgroundNotification: return "后台通知"
        case .vibrate: return "震动"
        default: return ""
        }
    }
}

class SettingsManager {
    class var refreshTimeInterval:Double {
        get {
            var v = UserDefaults.standard.double(forKey: "ASA_refreshTimeInterval")
            if v <= 0 {
                v = 7
            }
            return v
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "ASA_refreshTimeInterval")
        }
    }
    
    class var checkingAlertType:CheckingAlertType {
        get {
            if UserDefaults.standard.object(forKey: "ASA_checkingAlertType") == nil {
                return .all
            }
            
            return CheckingAlertType(rawValue: UserDefaults.standard.integer(forKey: "ASA_checkingAlertType"))
        }
        
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "ASA_checkingAlertType")
        }
    }
    
    class var checkingProductType:AppleStoreCheckingProduct {
        get {
            if UserDefaults.standard.object(forKey: "ASA_checkingProductType") == nil {
                return .all
            }
            
            return AppleStoreCheckingProduct(rawValue: UserDefaults.standard.integer(forKey: "ASA_checkingProductType"))
        }
        
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "ASA_checkingProductType")
        }
    }
}

struct SettingSectionItem {
    var title:String
    var items:[SettingItem] = []
}

struct SettingItem {
    var title:String
    var subtitle:()->String?
    var handler:()->Void
    var accessoryType:()->UITableViewCell.AccessoryType
}

class SettingsCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsViewController: UITableViewController {

    private var dataItems:[SettingSectionItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "设置"

        if true {
            var section = SettingSectionItem(title: "需要检查的产品")
            for product in AppleStoreCheckingProduct.allProduct {
                let item = SettingItem(title: product.name) { () -> String? in
                    return product.requestURL?.absoluteString
                } handler: {
                    var type = SettingsManager.checkingProductType
                    if type.contains(product) {
                        type.remove(product)
                    } else {
                        type.insert(product)
                    }
                    SettingsManager.checkingProductType = type
                } accessoryType: { () -> UITableViewCell.AccessoryType in
                    return SettingsManager.checkingProductType.contains(product) ? .checkmark : .none
                }
                section.items.append(item)
            }
            dataItems.append(section)
        }
        
        if true {
            var section = SettingSectionItem(title: "提醒相关")
            for alert in CheckingAlertType.allType {
                let item = SettingItem(title: alert.name) { () -> String? in
                    return nil
                } handler: {
                    var type = SettingsManager.checkingAlertType
                    if type.contains(alert) {
                        type.remove(alert)
                    } else {
                        type.insert(alert)
                    }
                    SettingsManager.checkingAlertType = type
                } accessoryType: { () -> UITableViewCell.AccessoryType in
                    return SettingsManager.checkingAlertType.contains(alert) ? .checkmark : .none
                }
                section.items.append(item)
            }
            dataItems.append(section)
        }
       
        if true {
            var section = SettingSectionItem(title: "控制参数")
            if true {
                let item = SettingItem(title: "刷新间隔") { () -> String in
                    return "\(SettingsManager.refreshTimeInterval)s"
                } handler: {
                    let alert = UIAlertController(title: "设置刷新间隔", message: nil, preferredStyle: .alert)
                    var storageTextFiled:UITextField?
                    alert.addTextField(configurationHandler: { textfield in
                        storageTextFiled = textfield
                        textfield.text = "\(SettingsManager.refreshTimeInterval)"
                    })
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                        if let text = storageTextFiled?.text, text.count > 0, let v = Double(text) {
                            SettingsManager.refreshTimeInterval = v
                        }
                        self.tableView.reloadData()
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                } accessoryType: { () -> UITableViewCell.AccessoryType in
                    return  .none
                }
                section.items.append(item)
            }
            dataItems.append(section)
        }
    
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataItems[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataItems[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle()
        cell.accessoryType = item.accessoryType()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = dataItems[indexPath.section].items[indexPath.row]
        item.handler()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
