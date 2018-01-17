//
//  customViewController.swift
//  SIAlertControllerDemo
//
//  Created by shahzaib on 1/17/18.
//  Copyright © 2018 shahzaib. All rights reserved.
//

import UIKit

class CustomViewController: SIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.preferredContentSize = CGSize(width: size.width * 0.75, height: self.preferredContentSize.height)
    }
    
    @IBAction func dismissController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
