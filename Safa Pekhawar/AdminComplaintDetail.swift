//
//  AdminComplaintDetail.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 08/11/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AdminComplaintDetail: UIViewController, NIDropDownDelegate {

    @IBOutlet var statusLbl_ur: UILabel!
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var statusView: UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var engLbl: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var compNumLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var detailTextView: UITextView!
    @IBOutlet var changeStatusBtn: UIButton!
    var dropdown:NIDropDown?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Clean KP"
        
        bgView.layer.cornerRadius = 10.0
        bgView.layer.shadowColor = UIColor.lightGray.cgColor
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        bgView.layer.shadowRadius = 1.0;
        
        statusView.layer.cornerRadius = 10.0
        statusView.backgroundColor = UIColor.green
        
        let complaint_detail: Dictionary = UserDefaults.standard.dictionary(forKey: "complaint_detail")!
        print(complaint_detail)
        
        engLbl.text = complaint_detail["c_type"] as? String
        //urduLbl.text = complaint_detail["c_type"] as? String;
        dateLbl.text = complaint_detail["c_date_time"] as? String
        detailTextView.text = complaint_detail["c_details"] as? String
        compNumLbl.text = complaint_detail["c_number"] as? String
        
        //image
        let imgPath: String = complaint_detail["image_path"] as! String
        let imgStr = "http://103.240.220.52/local_goverment/" + imgPath
        print(imgStr)
        let imgUrl = URL(string: imgStr as String)
        imageView.sd_setImage(with: imgUrl, completed: nil)
        
        let complaintType: String = UserDefaults.standard.value(forKey: "complaintt_type") as! String
        if complaintType == "inprogress"{
            statusView.backgroundColor = UIColor.yellow
            statusLbl.text = "InProgress"
            statusLbl_ur.text = "زیرجائزھ"
        }
        else if complaintType == "completed"{
            statusView.backgroundColor = UIColor.green
            statusLbl.text = "Completed"
            statusLbl_ur.text = "مکمل"

        }
        else if complaintType == "overdue"{
            let status_c = complaint_detail["status"] as? String
            if status_c == "inprogress"{
                statusView.backgroundColor = UIColor.yellow
                statusLbl.text = "InProgress"
                statusLbl_ur.text = "کام جاری ھے"
            }
            else if status_c == "pendingreview"{
                statusView.backgroundColor = UIColor.red
                statusLbl_ur.text = "زیرجائزھ"
                statusLbl.text = "Pending"
            }
        }
        
//        changeStatusBtn.layer.cornerRadius = 3.0
//        changeStatusBtn.layer.shadowColor = UIColor.lightGray.cgColor
//        changeStatusBtn.layer.shadowOpacity = 1
//        changeStatusBtn.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
//        changeStatusBtn.layer.shadowRadius = 1.0;
//        changeStatusBtn.layer.masksToBounds = true
    }
    
    @IBAction func changeStatus(_ sender: Any) {
        
        if dropdown == nil {
            dropdown = NIDropDown()
            
            let arr = ["Pending", "InProgress", "Completed", "Irrelevant"]
            
            dropdown = dropdown?.show(changeStatusBtn, 200, arr, nil, "down") as? NIDropDown
            dropdown?.delegate  = self
        }
        else{
            dropdown?.hide(changeStatusBtn)
            self.rel()
        }
    }
    
    func niDropDownDelegateMethod(_ sender: NIDropDown!) {
        self.rel()
    }
    
    func rel() {
        dropdown = nil
    }
    
    @IBAction func updateStatus(_ sender: Any) {
        let complaint_detail: Dictionary = UserDefaults.standard.dictionary(forKey: "complaint_detail")!
        let c_id: String = complaint_detail["c_id"] as! String
        let status: String = changeStatusBtn.title(for: UIControlState.normal)!
     
        if status == "Select Status" {
            let warning_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            warning_alert?.showWarning("incomplete info!", subTitle: "Please change status.", closeButtonTitle: "OK", duration: 0.0)
        }
        else{
            let waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            waiting_alert!.showWaiting("", subTitle: "Wait a while....", closeButtonTitle: nil, duration: 0.0)
            
            let urlString = "http://103.240.220.52/local_goverment/Admin/update_copmplaint"
            let parameter: Dictionary = ["complaint_number": c_id, "status": status] as [String : Any]
            Alamofire.request(urlString, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON(){
                response in
                waiting_alert?.hideView()
                switch response.result{
                case .success(let data):
                    print(data)
                    let response1 = JSON(data)
                    print(response1)
                    let message = response1["message"].stringValue
                    if message == "Complaint ID not found in our Records"{
                        let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                        error_alert?.showError("Error!", subTitle: "Complaint ID not found in our Records", closeButtonTitle: "OK", duration: 0.0)
                    }
                    else{
                        let success_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                        success_alert?.showSuccess("Success", subTitle: "Status changed successfully.", closeButtonTitle: "OK", duration: 0.0)
                        success_alert?.alertIsDismissed({
                            self.changeStatusBtn.setTitle("Select Status", for: UIControlState.normal)
                        })
                    }
                case .failure(let error):
                    print(error)
                    let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                    error_alert?.showError("Error!", subTitle: "Complaint ID not found in our Records", closeButtonTitle: "OK", duration: 0.0)
                }
            }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
