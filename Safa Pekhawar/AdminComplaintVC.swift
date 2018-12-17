//
//  AdminComplaintVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 08/11/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class AdminComplaintVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var noComplaint_lb: UILabel!
    @IBOutlet var menuBtn: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    var response: JSON = JSON.null
    var responseArr = [[String: AnyObject]]()
    
    var waiting_alert = SCLAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let complaintType: String = UserDefaults.standard.value(forKey: "complaintt_type") as! String
        if complaintType == "pending"{
            self.title = "Pending Complaints"
        }
        else if complaintType == "overdue"{
            self.title = "Overdue Complaint"
        }
        else if complaintType == "inprogress"{
            self.title = "Inprogress Complaint"
        }
        else if complaintType == "completed"{
            self.title = "Completed Complaint"
        }
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 250.0;
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.isHidden = true
        
        //alert
        waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
        waiting_alert.showWaiting("", subTitle: "Please Wait", closeButtonTitle: nil, duration: 0.0)
        
        if complaintType == "overdue" {
            self.perform(#selector(overdueComplaint), with: self, afterDelay: 1.0)
        }
        else{
            self.perform(#selector(mycomplaint), with: self, afterDelay: 1.0)
        }
    }
    
    @objc func mycomplaint() {
        
        let account_id: Int = UserDefaults.standard.integer(forKey: "account_id")

        var urlString = String()
        let complaintType: String = UserDefaults.standard.value(forKey: "complaintt_type") as! String
        
        if complaintType == "pending"{
            urlString = "http://103.240.220.52/local_goverment/Admin/all_complaints_pending_list"
        }
        else if complaintType == "inprogress"{
            urlString = "http://103.240.220.52/local_goverment/Admin/all_complaints_inprogress_list"
        }
        else if complaintType == "completed"{
            urlString = "http://103.240.220.52/local_goverment/Admin/all_complaints_completed_list"
        }
        let url = URL(string: urlString)
        
        let parameter: Dictionary = ["account_id": account_id]
        Alamofire.request(url!, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON(){
            URLResponse in
            self.waiting_alert.hideView()
            switch URLResponse.result{
            case .success(let data):
                self.response = JSON(data)
                if complaintType == "pending"{
                    self.responseArr = self.response["all_pending_complaints"].arrayObject as! [[String : AnyObject]]
                }
                else if complaintType == "inprogress"{
                    self.responseArr = self.response["all_inprogress_complaints"].arrayObject as! [[String : AnyObject]]
                }
                else if complaintType == "completed"{
                    self.responseArr = self.response["all_completed_complaints"].arrayObject as! [[String : AnyObject]]
                }
                print(self.responseArr)
                if self.responseArr.count == 0{
                    self.tableView.isHidden = true
                    self.noComplaint_lb.isHidden = false
                }
                else{
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.noComplaint_lb.isHidden = true
                }
            case .failure(let error):
                print(error)
                let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
            }
        }
    }
    
    @objc func overdueComplaint() {
        let str = String(format: "http://103.240.220.52/local_goverment/admin/over_due_complaints")
        let url = NSURL(string: str)
        var request1 = URLRequest(url: url! as URL)
        request1.httpMethod = "GET"
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request1 as URLRequestConvertible).responseJSON(){
            URLResponse in
            self.waiting_alert.hideView()
            switch URLResponse.result{
            case .success(let data):
                self.response = JSON(data)
                print(self.response)
                self.responseArr = self.response["over_due_complaints"].arrayObject as! [[String : AnyObject]]
                print(self.responseArr)
                if self.responseArr.count == 0{
                    self.tableView.isHidden = true
                    self.noComplaint_lb.isHidden = false
                }
                else{
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.noComplaint_lb.isHidden = true
                }
                
            case .failure(let error):
                print("error", error)
                let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseArr.count;
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
        
        label1.text = self.responseArr[indexPath.row]["c_number"] as? String
        label2.text = self.responseArr[indexPath.row]["status"] as? String
        label4.text = self.responseArr[indexPath.row]["c_date_time"] as? String
        
        let complaintType: String = UserDefaults.standard.value(forKey: "complaintt_type") as! String

        if complaintType == "overdue"{
            let status_c = self.responseArr[indexPath.row]["status"] as? String
            if status_c == "inprogress"{
                label3.text = "کام جاری ھے"
                label2.textColor = UIColor.darkGray
                label3.textColor = UIColor.darkGray
            }
            else if status_c == "pendingreview"{
                label3.text = "زیرجائزھ"
                label2.textColor = UIColor.blue
                label3.textColor = UIColor.blue
            }
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
        
        //image
        let imgPath: String = self.responseArr[indexPath.row]["image_path"] as! String
        let imgStr = NSString(format: "http://103.240.220.52/local_goverment/%@", imgPath)
        let imgUrl = URL(string: imgStr as String)
        print(imgUrl!)
        imgView.sd_setImage(with: imgUrl, completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic: [String: Any] = responseArr[indexPath.row]
        UserDefaults.standard.set(dic, forKey: "complaint_detail")
    }
}
