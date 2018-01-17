//
//  ViewController.swift
//  SIAlertControllerDemo
//
//  Created by shahzaib on 1/17/18.
//  Copyright © 2018 shahzaib. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionSheet(_ sender: Any) {
        // initialize your custom conrtoller
        let customSheet = self.storyboard?.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
        
        //Select presentation type. By defualt is alert
        customSheet.prefreredPresentationStyle = .actionSheet
        
        // You can always change size of alert by folowing line. In order get size from storyboard, go to storyboard and select your alert ViewController, in "Inspector attribute" set "Resize view from nib" property to false.
        //customSheet.preferredContentSize = CGSize(width: 330, height: 150)
        
        //Present your custom Alert
        self.present(customSheet, animated: true, completion: nil)
    }
    
    @IBAction func alert(_ sender: Any) {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomViewController") as! CustomViewController
        self.present(customAlert, animated: true, completion: nil)
    }

}

