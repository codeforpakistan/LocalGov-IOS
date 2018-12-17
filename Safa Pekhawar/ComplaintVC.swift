//
//  ComplaintVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 04/10/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SVProgressHUD
import SwiftyJSON

class ComplaintVC: UIViewController, CLLocationManagerDelegate, NIDropDownDelegate {

    @IBOutlet var disttBtn: UIButton!
    @IBOutlet var tehsilBtn: UIButton!
    @IBOutlet var bg_view: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var eng_lbl: UILabel!
    @IBOutlet var urdu_lbl: UILabel!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet var addressTF: UITextField!
    @IBOutlet var detailTV: UITextView!
    
    let locationMngr = CLLocationManager()
    var district_data:[[String]] = []
    var district = [String]()
    
    var waiting_alert = SCLAlertView()
    
    var image = UIImage()
    var dropdown:NIDropDown?
    var jsonResponse = JSON()
    //var db_Manager = DBManager()
    var db_Manager = DBManager.init(databaseFilename: "clean_kb_bd.db")
    var latitude = Float()
    var longitude = Float()
    var districtselected = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.perform(#selector(district_ftn), with: self, afterDelay: 1.0)
        
        eng_lbl.text = UserDefaults.standard.string(forKey: "complaint_type")
        //urdu_lbl.text = UserDefaults.standard.string(forKey: "complaint_type_ur")

        bg_view.layer.cornerRadius = 5.0;
        bg_view.layer.shadowColor = UIColor.lightGray.cgColor
        bg_view.layer.shadowOpacity = 1
        bg_view.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        bg_view.layer.shadowRadius = 1.0;
        
        submitBtn.layer.cornerRadius = 5.0;
        submitBtn.layer.shadowColor = UIColor.lightGray.cgColor
        submitBtn.layer.shadowOpacity = 1
        submitBtn.layer.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
        submitBtn.layer.shadowRadius = 3.0;
        
        imageView.image = image
        
        locationMngr.delegate = self
        locationMngr.desiredAccuracy = kCLLocationAccuracyBest
        locationMngr.requestWhenInUseAuthorization()
        locationMngr.startUpdatingLocation()
        
        districtselected = false
    }
    
    
    @objc func district_ftn() {
        let urlStr = "http://103.240.220.52/restapi/Districts"
        Alamofire.request(urlStr).responseJSON{ response in
            switch response.result{
            case .success(let data):
                self.jsonResponse = JSON(data)
                self.update_db()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func update_db()  {
        
        var arr = [[String: String]]()
        arr = self.jsonResponse["Data"].arrayObject as! [[String : String]]
        print(arr)
        let db_version: String = arr[0]["db_version"]!
        let db_v = UserDefaults.standard.value(forKey: "db_v") ?? "abbbaab"
        let db_v1 = String(format: "%@", db_v as! CVarArg)
        
        //check wether the value is changed or not!
        if db_version != db_v1{
            
            //delete all records
            let delete_query = "delete * from clean_kb_tb";
            db_Manager?.executeQuery(delete_query);
            
            //insert new records
            for i in 0...arr.count-1 {
                let server_id: String = arr[i]["id"]!
                let district: String = arr[i]["districts_categories"]!
                let tehsil: String = arr[i]["slug"]!
                let level: String = arr[i]["level"]!
                let parent_id: String = arr[i]["parent_id"]!
                let insert_query = String(format: "insert into clean_kb_tb values(null, '%@', '%@', '%@', '%@', '%@', '%@')", server_id, district, tehsil, level, parent_id, db_version)
                db_Manager!.executeQuery(insert_query)
            }
            
            UserDefaults.standard.setValue(db_version, forKey: "db_v")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print(location.coordinate.latitude)
        print(location.coordinate.longitude)
        latitude = Float(location.coordinate.latitude)
        longitude = Float(location.coordinate.longitude)
    }
    
    @IBAction func DistrictBtn(_ sender: Any) {
        if dropdown == nil {
            dropdown = NIDropDown()

            districtselected = true
            //get all records
            let select_query = "select * from clean_kb_tb where level='0'"
            
            district_data = NSArray.init(array: (self.db_Manager?.loadData(fromDB: select_query))!) as! [[String]]
            print(district_data)
            
            district.removeAll()
            for i in 0...district_data.count-1{
                let district_name = district_data[i][2]
                
                district.append(district_name)
            }
            dropdown = dropdown?.show(disttBtn, 200, district, nil, "down") as? NIDropDown
            dropdown?.delegate  = self
        }
        else{
            dropdown?.hide(disttBtn)
            self.rel()
        }
        UserDefaults.standard.set("district", forKey: "district_check")
    }
    
    @IBAction func tehsilBtn(_ sender: Any) {

        if districtselected == true {
            if dropdown == nil {
                dropdown = NIDropDown()
                let district_id: Int = UserDefaults.standard.integer(forKey: "district_idd")
                let select_query = String(format: "select * from clean_kb_tb where parent_id=%@", district_data[district_id][0])
                print(district_data[district_id][0])
                let tehsil_data:[[String]] = NSArray.init(array: (self.db_Manager?.loadData(fromDB: select_query))!) as! [[String]]
                print(tehsil_data)
                
                var tehsil = [String]()
                
                if(tehsil_data.count == 0){
                    self.view.makeToast("No tehsil!", duration: 3.0, position: .center)
                }
                else{
                    for i in 0...tehsil_data.count-1{
                        let tehsil_name = tehsil_data[i][2]
                        
                        tehsil.append(tehsil_name)
                    }
                    dropdown = dropdown?.show(tehsilBtn, 200, tehsil, nil, "down") as? NIDropDown
                    dropdown?.delegate  = self
                }
                
            }
            else{
                dropdown?.hide(disttBtn)
                self.rel()
            }
            
            UserDefaults.standard.set("tehsil", forKey: "district_check")
        }
        else{
            self.view.makeToast("First select district", duration: 3.0, position: .center)
        }
    }
    
    func niDropDownDelegateMethod(_ sender: NIDropDown!) {
        self.rel()
    }
    
    func rel() {
        dropdown = nil
    }
    
     @IBAction func add_complaint(_ sender: Any) {
        
        waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
        waiting_alert.showWaiting("", subTitle: "Sumbitting Complaint!", closeButtonTitle: nil, duration: 0.0)
        
        //current date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateStr = formatter.string(from: date)
        print(dateStr)
        
        let account_id = String(UserDefaults.standard.integer(forKey: "account_id"))
        let complaint_type = UserDefaults.standard.string(forKey: "complaint_type")
        let complaint_detail: String = detailTV.text
        let address: String = addressTF.text!
        let district_slug: String = (disttBtn.titleLabel?.text)!
        let tehsil_slug: String = (tehsilBtn.titleLabel?.text)!
        let lat: String = String(latitude)
        let lon: String = String(longitude)
        
        if addressTF.text == "" || detailTV.text == "" || disttBtn.titleLabel?.text == "District" || tehsilBtn.titleLabel?.text == "Tehsil" {
            let warning_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            warning_alert!.showWarning("", subTitle: "Please fill all fields", closeButtonTitle: "OK", duration: 0.0)
        }
        else{
            let imageData = UIImageJPEGRepresentation(imageView.image!, 1.0)
            let urlStr = "http://103.240.220.52/local_goverment/Admin/add_complaint"
            let url = URL(string: urlStr)
            
            //parameters
            let complaint_number = generateRandomStringWithLength(length: 5)
            let file: String = String(format: "%@.jpg", complaint_number)
            
            let parameter: [String: String] = ["account_id": account_id,
                             "c_number": complaint_number,
                             "c_type": complaint_type!,
                             "c_date_time": dateStr,
                             "c_details": complaint_detail,
                             "latitude": lat,
                             "longitude": lon,
                             "bin_address": address,
                             "status": "pendingreview",
                             "district_slug": district_slug,
                             "district_tma_slug": tehsil_slug]
            print(parameter)

            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in parameter {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                
                if imageData != nil{
                    multipartFormData.append(imageData!, withName: "image_path", fileName: file, mimeType: "image/jpg")
                }
                
            }, to: url!) { (result) in
                switch result{
                case .success(let upload, _, _):

                    upload.responseJSON { response in
                        self.waiting_alert.hideView()

                        let json_dic = JSON(response.result.value!)
                        print(json_dic)
                        let message = json_dic["status"].stringValue
                        if message == "Successfully Registered!"{
                            let success_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                            success_alert?.showSuccess("Success", subTitle: "Complaint is successfully submitted.", closeButtonTitle: "OK", duration: 0.0)
                            success_alert?.alertIsDismissed({
                                self.disttBtn.setTitle("District", for: UIControlState.normal)
                                self.tehsilBtn.setTitle("Tehsil", for: UIControlState.normal)
                                self.addressTF.text = ""
                                self.detailTV.text = ""
                            })
                        }
                        else if message == "You did not select a file to upload"{
                            let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                            error_alert?.showError("Alert!", subTitle: "You did not select a file to upload!", closeButtonTitle: "OK", duration: 0.0)
                        }
                        else{
                            let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                            error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
                        }
                    }
                case .failure(let error):
                    self.waiting_alert.hideView()
                    print(error)
                    let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                    error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
                }
            }
        }
}
    
    func generateRandomStringWithLength(length:Int) -> String {
        
        let randomString:NSMutableString = NSMutableString(capacity: length)
        
        let letters:NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var i: Int = 0
        
        while i < length {
            
            let randomIndex:Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }

		return String(randomString)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//    func ftn() {
//
//
//        let parameter: [String: String] = ["account_id": "2323",
//                                           "c_number": "2323",
//                                           ]
//
//        let url = NSURL(string: "http://103.240.220.52/local_goverment/index.php/main/add_comp/add")
//        let request: NSMutableURLRequest = NSMutableURLRequest(url: url! as URL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        let boundary: String = "qqqq___winter_is_coming_!___qqqq"
//        let content_type: String = String(format: "multipart/form-data; boundary:%@", boundary)
//        request.setValue(content_type, forHTTPHeaderField: "Content-Type")
//        let body: NSMutableData = NSMutableData()
//
//        for(key, value) in parameter{
//            body.append(String(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
//            body.append(String(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key).data(using: String.Encoding.utf8)!)
//            body.append(String(format: "%@\r\n", key).data(using: String.Encoding.utf8)!)
//        }
//
//        let imgData = UIImagePNGRepresentation(imageView.image!)
//        if imgData != nil {
//            body.append(String(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
//            body.append(String(format: "Content-Disposition: form-data; name=\"image_path\"; filename=\"%@\"\r\n", "file").data(using: String.Encoding.utf8)!)
//            body.append(String(format: "Content-Type: image/jpeg\r\n\r\n").data(using: String.Encoding.utf8)!)
//            body.append(imgData!)
//            body.append(String(format: "\r\n").data(using: String.Encoding.utf8)!)
//        }
//
//        body.append(String(format: "--%@--\r\n", boundary).data(using: String.Encoding.utf8)!)
//        request.httpBody = body as Data
//
//        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            let dictionary = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//            print(dictionary)
//        }
//        task.resume()
//    }
