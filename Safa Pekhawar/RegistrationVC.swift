//
//  RegistrationVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 25/09/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegistrationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var addressTF: UITextField!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    @IBOutlet var label5: UILabel!
    
    var response: JSON = JSON.null
    var waiting_alert = SCLAlertView()
    var i:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        signUpBtn.layer.cornerRadius = 5.0;
        signUpBtn.layer.shadowColor = UIColor.lightGray.cgColor
        signUpBtn.layer.shadowOpacity = 1
        signUpBtn.layer.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
        signUpBtn.layer.shadowRadius = 3.0;
        
        
        nameTF.delegate = self
        phoneTF.delegate  = self
        emailTF.delegate  = self
        passwordTF.delegate  = self
        addressTF.delegate  = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(nameTF) {
            label1.backgroundColor = UIColor.blue
            label2.backgroundColor = UIColor.gray
            label3.backgroundColor = UIColor.gray
            label4.backgroundColor = UIColor.gray
            label5.backgroundColor = UIColor.gray
        }
        else if textField.isEqual(phoneTF){
            label1.backgroundColor = UIColor.gray
            label2.backgroundColor = UIColor.blue
            label3.backgroundColor = UIColor.gray
            label4.backgroundColor = UIColor.gray
            label5.backgroundColor = UIColor.gray
        }
        else if textField.isEqual(emailTF){
            label1.backgroundColor = UIColor.gray
            label2.backgroundColor = UIColor.gray
            label3.backgroundColor = UIColor.blue
            label4.backgroundColor = UIColor.gray
            label5.backgroundColor = UIColor.gray
        }
        else if textField.isEqual(passwordTF){
            label1.backgroundColor = UIColor.gray
            label2.backgroundColor = UIColor.gray
            label3.backgroundColor = UIColor.gray
            label4.backgroundColor = UIColor.blue
            label5.backgroundColor = UIColor.gray
        }
        else if textField.isEqual(addressTF){
            label1.backgroundColor = UIColor.gray
            label2.backgroundColor = UIColor.gray
            label3.backgroundColor = UIColor.gray
            label4.backgroundColor = UIColor.gray
            label5.backgroundColor = UIColor.blue
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
    
    @IBAction func resgistrationBtn(_ sender: Any) {

        if nameTF.text == "" || phoneTF.text == "" || emailTF.text == "" || addressTF.text == "" || passwordTF.text == ""  {
            let warning_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            warning_alert?.showWarning("incomplete info!", subTitle: "Please fill all fields.", closeButtonTitle: "OK", duration: 0.0)
        }
        else{
            
            //alert
            waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
            waiting_alert.showWaiting("", subTitle: "Wait a while....", closeButtonTitle: nil, duration: 0.0)
            
            let urlStr = "http://103.240.220.52/local_goverment/user/user_register"
            let parameter: [String: String] = ["name": nameTF.text!, "phone": phoneTF.text!, "email": emailTF.text!, "address": addressTF.text!, "password": passwordTF.text!]
            Alamofire.request(urlStr, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON(){
                response in
                
                self.waiting_alert.hideView()
                switch response.result{
                case .success(let data):
                    self.response = JSON(data)
                    
                    print(data)
                    let status = self.response["success"].stringValue
                    if status == "User Registered Successfully"{
                        let success_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                        success_alert?.showSuccess("Success", subTitle: "User Registered Successfully", closeButtonTitle: "OK", duration: 0.0)
                        success_alert?.alertIsDismissed({
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
                            self.navigationController?.pushViewController(vc!, animated: false)
                        })
                    }
                    else{
                        let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                        error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
                    }
                case .failure(let error):
                    print(error)
                    let error_alert1 = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                    error_alert1?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
                }
            }
        }
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.revealViewController()?.pushFrontViewController(vc, animated: false)
        self.navigationController?.pushViewController(vc!, animated: false)
    }
}
