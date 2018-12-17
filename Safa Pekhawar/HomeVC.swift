//
//  HomeVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 26/09/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var bg_view: UIView!
    @IBOutlet var eng_title: UILabel!
    @IBOutlet var ur_title: UILabel!
    @IBOutlet var menuBtn: UIBarButtonItem!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var pageController: UIPageControl!
    var myResponse : JSON = JSON.null

    var data = [[String: Any]]()
    var waiting_alert = SCLAlertView()

    
//    let title1_arr: NSArray = ["Drainage", "Trash Bin", "Water Supply", "Garbage", "Other",]
    let title2_arr: NSArray = ["نکاسی اب", "بھرا ھوا گند کا ڈبہ", " پانی کا مسلہ", " کوڑاکرکٹ" ,"کویں اورمسلہ",]
//
//    let img_arr: NSArray = ["drainage.jpg", "trashbin.JPG", "water.jpg", "garbage.png", "plus.png",]

    let imgPicker = UIImagePickerController()
    var image1 = UIImage()
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var imgView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Clean KP";
        
       // self.view.backgroundColor = UIColor.white
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 300.0;
        }

        bg_view.layer.cornerRadius = 5.0
        
        selectBtn.layer.cornerRadius = 5.0;
        selectBtn.layer.shadowColor = UIColor.lightGray.cgColor
        selectBtn.layer.shadowOpacity = 1
        selectBtn.layer.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
        selectBtn.layer.shadowRadius = 3.0;
        
        imgPicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
        waiting_alert.showWaiting("", subTitle: "Please wait", closeButtonTitle: nil, duration: 0.0)
        self.perform(#selector(complaint_type), with: self, afterDelay: 1.0)
    }
    
    @objc func complaint_type() {
        
        let str = String(format: "http://103.240.220.52/local_goverment/index.php/main/complaint_types")
        
        let url = NSURL(string: str)
        var request1 = URLRequest(url: url! as URL)
        request1.httpMethod = "GET"
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request1 as URLRequestConvertible).responseJSON(){
            URLResponse in
            self.waiting_alert.hideView()
            switch URLResponse.result{
            case .success(let data):
                print(data)
                self.myResponse = JSON(data)
                let message = self.myResponse["message"].string
                if message == "Complaint Types"{
                    self.setComplaintType()
                }
                else{
                    let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                    error_alert?.showError("Error!", subTitle: "Some thing went wrong.", closeButtonTitle: "OK", duration: 0.0)
                }
            case .failure(let error):
                print(error)
                let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                error_alert?.showError("Error!", subTitle: "Some thing went wrong.", closeButtonTitle: "OK", duration: 0.0)
            }
        }

    }
    
    func setComplaintType() {
        data = self.myResponse["data"].arrayObject as! [[String : Any]]
        
        for i in 0..<(data.count)-1 {
            eng_title.text = data[i]["complaint_types"] as? String
            //ur_title.text = title2_arr[0] as? String
            
            UserDefaults.standard.set(0, forKey: "complaint_number")
            UserDefaults.standard.set(eng_title.text, forKey: "complaint_type")
            //UserDefaults.standard.set(title2_arr[0], forKey: "complaint_type_ur")
        }
        
        pageController.numberOfPages = data.count
        for index in 0..<data.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            imgView = UIImageView(frame: frame)
            let imgPath: String = data[index]["image"] as! String
            let imgUrl = URL(string: imgPath as String)
            imgView.sd_setImage(with: imgUrl, completed: nil)
            self.scrollView.addSubview(imgView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width*CGFloat(data.count), height: scrollView.frame.size.height)
        self.scrollView.delegate = self
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = scrollView.contentOffset.x/scrollView.frame.size.width
        pageController.currentPage = Int(pageNumber)
        
//        if pageController.currentPage == 3 {
//            imgView.contentMode = UIViewContentMode.scaleAspectFit
//        }
//        else{
//            imgView.contentMode = UIViewContentMode.scaleToFill
//        }
        
//        imgView.image = UIImage(named: data[pageController.currentPage]["image"] as! String)
        eng_title.text = data[pageController.currentPage]["complaint_types"] as? String
        //ur_title.text = title2_arr[pageController.currentPage] as? String
        
        UserDefaults.standard.set(data[pageController.currentPage]["complaint_types"], forKey: "complaint_type")
       // UserDefaults.standard.set(ur_title.text, forKey: "complaint_type_ur")
    }
    
    @IBAction func pageController(_ sender: Any) {
        
//        if pageController.currentPage == 4 {
//            imageView.backgroundColor = UIColor.white
//        }
//        else{
//            imageView.backgroundColor = UIColor.blue
//        }
//
//        imageView.image = UIImage(named: img_arr[pageController.currentPage] as! String)
//        eng_title.text = title1_arr[pageController.currentPage] as? String
//        ur_title.text = title2_arr[pageController.currentPage] as? String
//
//        UserDefaults.standard.set(pageController.currentPage, forKey: "complaint_number")
//        UserDefaults.standard.set(eng_title.text, forKey: "complaint_type")
//        UserDefaults.standard.set(ur_title.text, forKey: "complaint_type_ur")
    }
    
    @IBAction func selectBtn(_ sender: Any) {
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .camera
        present(imgPicker, animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .camera
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image1 = info[UIImagePickerControllerOriginalImage] as! UIImage
        
//        let img_url: URL = info[UIImagePickerControllerImageURL] as! URL
//        let img_str: String = img_url.absoluteString
//
        UserDefaults.standard.set("img_str", forKey: "img_url_str")
        
        dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "complaint_segue", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ComplaintVC
        vc?.image = image1
    }
}
