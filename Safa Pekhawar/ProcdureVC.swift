//
//  ProcdureVC.swift
//  Safa Pekhawar
//
//  Created by Romi_Khan on 05/10/2018.
//  Copyright © 2018 SoftBrain. All rights reserved.
//

import UIKit

class ProcdureVC: UIViewController {

    @IBOutlet var menuBtn: UIBarButtonItem!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var bg_view: UIView!
    
    @IBOutlet var urdu_lbl: UILabel!
    @IBOutlet var eng_lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bg_view.layer.cornerRadius = 10.0
        bg_view.layer.shadowColor = UIColor.lightGray.cgColor
        bg_view.layer.shadowOpacity = 1
        bg_view.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        bg_view.layer.shadowRadius = 3.0;
        
        urdu_lbl.isHidden = true
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 300.0;
        }
    }
    
    @IBAction func segmentMtd(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            urdu_lbl.isHidden = true
            eng_lbl.isHidden = false
        }
        else{
            urdu_lbl.isHidden = false
            eng_lbl.isHidden = true
        }
    }
}
