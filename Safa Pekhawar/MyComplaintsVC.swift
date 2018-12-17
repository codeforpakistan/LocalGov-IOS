//
//  MyComplaintsVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 01/10/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD
import SDWebImage

class MyComplaintsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var notice_lbl: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var menuBtn: UIBarButtonItem!
    var response: JSON = JSON.null
    var waiting_alert = SCLAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Clean KP";

        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 300.0;
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.isHidden = true
        notice_lbl.isHidden = true
        
        //alert
        waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
        waiting_alert.showWaiting("", subTitle: "Please Wait", closeButtonTitle: nil, duration: 0.0)
        self.perform(#selector(mycomplaint), with: self, afterDelay: 1.0)
    }
    
    @objc func mycomplaint() {
     
        let urlString = "http://103.240.220.52/local_goverment/main/add_comp/list"
        let url = URL(string: urlString)
        let phone: String = UserDefaults.standard.value(forKey: "mobilenumber") as! String
        
        let parameter: Dictionary = ["mobilenumber": phone]
        Alamofire.request(url!, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON(){
            URLResponse in
            self.waiting_alert.hideView()
            switch URLResponse.result{
            case .success(let data):
                self.response = JSON(data)
                print(self.response)
                self.tableView.reloadData()
                if self.response.count == 0{
                    self.notice_lbl.isHidden = false
                    self.tableView.isHidden = true
                }
                else{
                    self.notice_lbl.isHidden = true
                    self.tableView.isHidden = false
                }
            case .failure(let error):
                print(error)
                let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_identifier", for: indexPath)
        let view: UIView = cell.viewWithTag(1)!
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        view.layer.shadowRadius = 1.0;
        
        let imgView: UIImageView = cell.viewWithTag(2) as! UIImageView
        imgView.layer.cornerRadius = 10.0
        imgView.layer.masksToBounds = true
        
        let label1: UILabel = cell.viewWithTag(3) as! UILabel
        let label2: UILabel = cell.viewWithTag(4) as! UILabel
        let label3: UILabel = cell.viewWithTag(5) as! UILabel
        let label4: UILabel = cell.viewWithTag(6) as! UILabel

        let complaintType = self.response[indexPath.row]["status"].stringValue
        
        label2.text = complaintType
        if complaintType == "overdue"{
            label3.text = "زیرجائزھ"
            label2.textColor = UIColor.blue
            label3.textColor = UIColor.blue
        }
        else if complaintType == "inprogress"{
            label3.text = "کام جاری ھے"
            label2.textColor = UIColor.darkGray
            label3.textColor = UIColor.darkGray
        }
        else if complaintType == "completed"{
            label3.text = "مکمل"
            label2.textColor = UIColor.green
            label3.textColor = UIColor.green
        }
        else if complaintType == "pendingreview"{
            label3.text = "زیرجائزھ"
            label2.textColor = UIColor.blue
            label3.textColor = UIColor.blue
        }
        
        label1.text = self.response[indexPath.row]["c_number"].stringValue
        label4.text = self.response[indexPath.row]["c_date_time"].stringValue
        
        //image
        let imgPath = self.response[indexPath.row]["image_path"].stringValue
        let imgStr = NSString(format: "http://103.240.220.52/local_goverment/uploads/map/%@", imgPath)
        let imgUrl = URL(string: imgStr as String)
        print(imgUrl!)
        imgView.sd_setImage(with: imgUrl, completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ComplaintDetailVC")
//        self.navigationController?.pushViewController(vc!, animated: true)
        let dic: [String: Any] = self.response[indexPath.row].dictionaryObject!
        UserDefaults.standard.set(dic, forKey: "complaint_detail")
    }
}
