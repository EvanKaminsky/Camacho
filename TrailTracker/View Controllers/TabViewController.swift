//
//  TabViewController.swift
//  TrailTracker
//
//  Created by Natasha Solanki on 4/22/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    @IBOutlet weak var mainTabBar: UITabBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:"SUNN", size:25)!, NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:"SUNN", size:25)!, NSAttributedStringKey.foregroundColor: UIColor.green], for: .selected)
        
          // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
