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
    }

}
