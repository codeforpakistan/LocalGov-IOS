//
//  AdminHomeV.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 07/11/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AdminHomeV: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    
    @IBOutlet var pieView: UIView!
    @IBOutlet var tableView: UITableView!
    var myResponse : JSON = JSON.null
    var waiting_alert = SCLAlertView()
    
    @IBOutlet var menuBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.layer.cornerRadius = label1.frame.size.height*0.5
        label1.layer.masksToBounds = true
        label2.layer.cornerRadius = label2.frame.size.height*0.5
        label2.layer.masksToBounds = true
        label3.layer.cornerRadius = label3.frame.size.height*0.5
        label3.layer.masksToBounds = true
        label4.layer.cornerRadius = label4.frame.size.height*0.5
        label4.layer.masksToBounds = true

        // self.view.backgroundColor = UIColor.white
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 250.0;
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        waiting_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
        waiting_alert.showWaiting("", subTitle: "Wait a while....", closeButtonTitle: nil, duration: 0.0)
        self.perform(#selector(allComplaints), with: self, afterDelay: 1.0)
        
    }
    
    @objc func allComplaints() {
        
        let account_id: Int = UserDefaults.standard.integer(forKey: "account_id")
        
        let str = String(format: "http://103.240.220.52/local_goverment/Admin/all_complaints?account_id=%i", account_id)
        let url = NSURL(string: str)
        var request1 = URLRequest(url: url! as URL)
        request1.httpMethod = "GET"
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request1 as URLRequestConvertible).responseJSON(){
            URLResponse in
            self.waiting_alert.hideView()
            switch URLResponse.result{
            case .success(let data):
                self.myResponse = JSON(data)
                print(self.myResponse)
                let pieChart = self.setPieChart()
                self.view.addSubview(pieChart)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
                let error_alert = SCLAlertView.init(newWindowWidth: self.view.frame.size.width-50)
                error_alert?.showError("Error!", subTitle: "Something went wrong!", closeButtonTitle: "OK", duration: 0.0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_identifier")!
        let label1: UILabel = cell.viewWithTag(1) as! UILabel
        let label2: UILabel = cell.viewWithTag(2) as! UILabel
        let bg_view:UIView = cell.viewWithTag(3)!
        bg_view.backgroundColor = UIColor.white
        bg_view.layer.borderWidth = 1.0
        bg_view.layer.borderColor = UIColor.green.cgColor
        
        if indexPath.row==0 {
            label1.text = "Total Complaints"
            label2.text = String(format: "%i", self.myResponse["all_complaints"].intValue)
        }
        else if indexPath.row == 1{
            label1.text = "Pending Complaints"
            label2.text = String(format: "%i", self.myResponse["pending_complaints"].intValue)
        }
        else if indexPath.row == 2{
            label1.text = "Completed Complaints"
            label2.text = String(format: "%i", self.myResponse["completed_complaints"].intValue)
        }
        else if indexPath.row == 3{
            label1.text = "Overdue Complaints"
            label2.text = String(format: "%i", self.myResponse["over_due_complaints"].intValue)
        }
        else if indexPath.row == 4{
            label1.text = "Inprogress Complaints"
            label2.text = String(format: "%i", self.myResponse["inprogress_complaints"].intValue)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            UserDefaults.standard.set("pending", forKey: "complaintt_type")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
            self.revealViewController()?.pushFrontViewController(vc, animated: true)
        }
        else if indexPath.row == 2{
            UserDefaults.standard.set("completed", forKey: "complaintt_type")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
            self.revealViewController()?.pushFrontViewController(vc, animated: true)
        }
        else if indexPath.row == 3{
            UserDefaults.standard.set("overdue", forKey: "complaintt_type")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
            self.revealViewController()?.pushFrontViewController(vc, animated: true)
        }
        else if indexPath.row == 4{
            UserDefaults.standard.set("inprogress", forKey: "complaintt_type")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "navigation")
            self.revealViewController()?.pushFrontViewController(vc, animated: true)
        }
    }
    
    private func setPieChart() -> PNPieChart {
        let completed: CGFloat = CGFloat(myResponse["completed_complaints"].intValue)
        let inprogress: CGFloat = CGFloat(myResponse["inprogress_complaints"].intValue)
        let pending: CGFloat = CGFloat(myResponse["pending_complaints"].intValue)
        let overdue: CGFloat = CGFloat(myResponse["over_due_complaints"].intValue)
        
        var itemArr = [Any]()
        
        if completed>0 {
            let item1 = PNPieChartDataItem(dateValue: completed, dateColor:  PNGreen, description: "")
            itemArr.append(item1)
        }
        if inprogress>0 {
            let item2 = PNPieChartDataItem(dateValue: inprogress, dateColor: PNGrey, description: "")
            itemArr.append(item2)
        }
        if pending>0 {
            let item3 = PNPieChartDataItem(dateValue: pending, dateColor: PNBule, description: "")
            itemArr.append(item3)
        }
        if overdue>0 {
            let item4 = PNPieChartDataItem(dateValue: overdue, dateColor: PNRed, description: "")
            itemArr.append(item4)
        }
        let frame = CGRect(x: pieView.frame.origin.x, y: pieView.frame.origin.y, width: pieView.frame.size.height, height: pieView.frame.size.height)
        let items: [PNPieChartDataItem] = itemArr as! [PNPieChartDataItem]
        let pieChart = PNPieChart(frame: frame, items: items)
        pieChart.descriptionTextColor = UIColor.white
        pieChart.descriptionTextFont = UIFont(name: "Avenir-Medium", size: 14)!
        //pieChart.center = self.view.center
        return pieChart
    }
}
