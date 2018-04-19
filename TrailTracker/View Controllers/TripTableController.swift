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
        
        let width = 0.2 * self.view.width
        let button = CamachoButton(frame: CGRect(x: 0, y: 0, width: width, height: width), text: "Start", backgroundColor: Color.forest)
        button.center = CGPoint(x: 0.5 * view.width, y: 0.85 * view.height)
        self.view.addSubview(button)
        

        
        
        
    }
    
    
}
