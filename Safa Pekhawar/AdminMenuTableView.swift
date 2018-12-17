//
//  AdminMenuTableView.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 07/11/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit

class AdminMenuTableView: UITableViewController {

    let menu = ["header", "first", "second", "third", "fourth", "fifth"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        
        let button = UIButton();
        button.setTitle("LogOut | لاگ اوٹ", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 218/255, blue: 60/255, alpha: 1.0)
        button.frame = CGRect(x: 0, y: self.view.frame.height-60, width: 300, height: 40)
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(button_pressed), for: .touchUpInside)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_identifier: String = menu[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cell_identifier, for: indexPath)
        if indexPath.row == 0 {
            let label: UILabel = cell.viewWithTag(99) as! UILabel
            label.text = UserDefaults.standard.value(forKey: "username") as? String
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        else{
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            UserDefaults.standard.set("pending", forKey: "complaintt_type")
        }
        else if indexPath.row == 3{
            UserDefaults.standard.set("overdue", forKey: "complaintt_type")
        }
        else if indexPath.row == 4{
            UserDefaults.standard.set("inprogress", forKey: "complaintt_type")
        }
        else if indexPath.row == 5{
            UserDefaults.standard.set("completed", forKey: "complaintt_type")
        }
    }
    
    @objc func button_pressed() {
        UserDefaults.standard.set(false, forKey: "login_status")
        let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.revealViewController()?.pushFrontViewController(vc, animated: true)
    }
}
