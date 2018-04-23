//
//  ParticipantViewController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class ParticipantViewController: UIViewController {
    
    // Fields
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var guardianInfoLabel: UILabel!
    @IBOutlet weak var durationBadge: Badge!
    @IBOutlet weak var distanceBadge: Badge!
    
    var member: Member!
    
    
    // Methods //
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = member.full_name
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set member before coming here!
        
        // Nav Bar
        //navigationController?.navigationBar.barTintColor = Color.forest
        //navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        // Table
        //tableView.register(TripTableController, forCellReuseIdentifier: "TripTableCell")
        
    }
    
    
}
