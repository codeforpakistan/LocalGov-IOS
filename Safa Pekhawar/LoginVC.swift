//
//  LoginVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 25/09/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label1: UILabel!
    
    var json_response: JSON = JSON.null
    var waiting_alert = SCLAlertView()
    var i:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        loginBtn.layer.cornerRadius = 5.0;
        loginBtn.layer.shadowColor = UIColor.lightGray.cgColor
        loginBtn.layer.shadowOpacity = 1
        loginBtn.layer.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
        loginBtn.layer.shadowRadius = 3.0;
        
        phoneTF.delegate = self
        passwordTF.delegate  = self
        
        //user
//        phoneTF.text = "03369189596"
//        passwordTF.text = "bilawal"
        
//        admin
//        03358018012
//        123456789
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(phoneTF) {
            label1.backgroundColor = UIColor.blue
            label2.backgroundColor = UIColor.gray
        }
        else{
            label2.backgroundColor = UIColor.blue
            label1.backgroundColor = UIColor.gray
        }
    }
    
    @IBAction func showPasswordBtn(_ sender: Any) {
        if i%2==0 {
            passwordTF.isSecureTextEntry = false
        }
        else{
            passwordTF.isSecureTextEntry = true
        }
        i = i+1;
    }

    @IBAction func loginBtn(_ sender: Any) {
        //SVProgressHUD.show()
        if phoneTF.text == "" || passwordTF.text == "" {
            let warning_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            warning_alert!.showWarning("incomplete info!", subTitle: "Please fill all fields.", closeButtonTitle: "OK", duration: 0.0)
        }
        else{
            //alert
            waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            waiting_alert.showWaiting("", subTitle: "Getting Login", closeButtonTitle: nil, duration: 0.0)
            
            let urlString = "http://103.240.220.52/local_goverment/index.php/main/login_validations"
            
            let phone: String = phoneTF.text!
            let password: String = passwordTF.text!
            let parameter: Dictionary = ["mobilenumber": phone, "password": password]

            Alamofire.request(urlString, method: .post, parameters: parameter ,encoding: URLEncoding.default, headers: nil).responseJSON {
                response in
                //hide alert
                self.waiting_alert.hideView()
                switch response.result {
                case .success(let data):
                    self.json_response = JSON(data)
                    print(data)
                    let status = self.json_response["status"].stringValue
                    if status == "Success"{
                        //SVProgressHUD.dismiss()
                    UserDefaults.standard.setValue(self.json_response["user_type"].stringValue, forKey: "user_type")
                    UserDefaults.standard.setValue(self.json_response["account_id"].intValue, forKey: "account_id")
                    UserDefaults.standard.set(self.json_response["username"].stringValue, forKey: "username")
                        
                        let user_type = self.json_response["user_type"].stringValue
                        
                    UserDefaults.standard.setValue(user_type, forKey: "user_type")
                    UserDefaults.standard.setValue(self.json_response["mobilenumber"].stringValue, forKey: "mobilenumber")
                        UserDefaults.standard.set(true, forKey: "login_status")
                        if user_type == "admin"{
                            let account_id: Int = self.json_response["account_id"].intValue
                            
                       UserDefaults.standard.set(account_id, forKey: "account_id")
                            let vc: SWRevealViewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController1") as! SWRevealViewController
                            self.revealViewController()?.pushFrontViewController(vc, animated: true)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else{
                            let vc: SWRevealViewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                            self.revealViewController()?.pushFrontViewController(vc, animated: true)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                            
                    }
                    else{
                        let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                        error_alert?.showError("Error!", subTitle: "Incorrect phone number or passowrd!", closeButtonTitle: "OK", duration: 0.0)
                    }
                case .failure(let error):
                    print(error)
                    let error_alert1 = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                    error_alert1?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
                }
            }
        }
    }
    
    @IBAction func aboutBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutVC")
        self.revealViewController()?.pushFrontViewController(vc, animated: false)
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func problemBtn(_ sender: Any) {
        let vc = UIActivityViewController(activityItems: [""], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC")
        self.revealViewController()?.pushFrontViewController(vc, animated: false)
        self.navigationController?.pushViewController(vc!, animated: false)
    }
}
