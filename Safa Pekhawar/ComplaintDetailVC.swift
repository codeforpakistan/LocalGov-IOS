//
//  ComplaintDetailVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 01/10/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit

class ComplaintDetailVC: UIViewController {

    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var statusLbl_ur: UILabel!
    @IBOutlet var statusView: UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var engLbl: UILabel!
    @IBOutlet var urduLbl: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var compNumLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var detailTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Clean KP"
        
        bgView.layer.cornerRadius = 10.0
        bgView.layer.shadowColor = UIColor.lightGray.cgColor
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        bgView.layer.shadowRadius = 1.0;
        
        statusView.layer.cornerRadius = 10.0
        //statusView.backgroundColor = UIColor.green
        
        let complaint_detail: Dictionary = UserDefaults.standard.dictionary(forKey: "complaint_detail")!
        print(complaint_detail)
        
        let complaintType: String = complaint_detail["status"] as! String
        
        statusLbl.text = complaint_detail["status"] as? String
        if complaintType == "overdue"{
            statusLbl_ur.text = "زیرجائزھ"
            statusView.backgroundColor = UIColor.red
        }
        else if complaintType == "inprogress"{
            statusLbl_ur.text = "کام جاری ھے"
            statusView.backgroundColor = UIColor.darkGray
        }
        else if complaintType == "completed"{
            statusLbl_ur.text = "مکمل"
            statusView.backgroundColor = UIColor.green
        }
        else if complaintType == "pendingreview"{
            statusLbl_ur.text = "زیرجائزھ"
            statusView.backgroundColor = UIColor.blue
        }
        
        engLbl.text = complaint_detail["c_type"] as? String
        //urduLbl.text = complaint_detail["c_type"] as? String;
        dateLbl.text = complaint_detail["c_date_time"] as? String
        detailTextView.text = complaint_detail["c_details"] as? String
        compNumLbl.text = complaint_detail["c_number"] as? String
        
        //image
        let imgPath: String = complaint_detail["image_path"] as! String
        let imgStr = "http://103.240.220.52/local_goverment/uploads/map/" + imgPath
        print(imgStr)
        let imgUrl = URL(string: imgStr as String)
        imageView.sd_setImage(with: imgUrl, completed: nil)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
