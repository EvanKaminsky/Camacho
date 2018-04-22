//
//  TripTableCell.swift
//  TrailTracker
//
//  Created by Natasha Solanki on 4/16/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class TripTableCell: UITableViewCell {

    // Outlets //
    
    @IBOutlet weak var tripLabel: UILabel?
    @IBOutlet weak var participantsLabel: UILabel?
    
    @IBOutlet weak var staffLabel: UILabel?
    @IBOutlet weak var milesLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    
    
    // Methods //
    
    func update(with trip: Trip) {
        
    }

}
