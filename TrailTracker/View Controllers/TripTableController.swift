//
//  TripTableController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit
import CoreLocation

class TripTableController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        // Test Camacho Button (TODO: Put in front of toolbar)
        let button_width = 0.2 * view.width
        let button = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Start", backgroundColor: Color.forest)
        button.center = CGPoint(x: 0.5 * view.width, y: 0.85 * view.height)
        self.view.addSubview(button)
        
        // Test Badges (TODO: Add to table cells and overlay mapview in the TripViewController)
        let badge_width = 0.14 * view.width
        let badge_height = 0.04 * view.height
        let badge_1 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "3 Trips", backgroundColor: Color.blue)
        let badge_2 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "28.1 mi.", backgroundColor: Color.green)
        let badge_3 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "36 min", backgroundColor: Color.red)
        badge_1.center = CGPoint(x: 0.12 * view.width, y: 0.14 * view.height)
        badge_2.center = CGPoint(x: 0.12 * view.width, y: 0.19 * view.height)
        badge_3.center = CGPoint(x: 0.12 * view.width, y: 0.24 * view.height)
        self.view.addSubview(badge_1)
        self.view.addSubview(badge_2)
        self.view.addSubview(badge_3)
        
        // Test Member Type Button
        let member_width = 0.35 * view.width
        let member_height = 0.07 * view.height
        let member_button_1 = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Staff", image: "staff", isSelected: true, themeColor: Color.orange)
        member_button_1.center = CGPoint(x: 0.7 * view.width, y: 0.15 * view.height)
        member_button_1.touchUpInside = { button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
            member_button_1.toggleSelected()
        }
        
        let member_button_2 = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Participant", image: "peep", isSelected: true, themeColor: Color.blue)
        member_button_2.center = CGPoint(x: 0.7 * view.width, y: 0.25 * view.height)
        member_button_2.touchUpInside = { button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
            member_button_2.toggleSelected()
        }
            
        self.view.addSubview(member_button_1)
        self.view.addSubview(member_button_2)
        
    }
    
    
    
    
    
    
    
}
