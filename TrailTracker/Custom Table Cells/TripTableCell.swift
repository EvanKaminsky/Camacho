//
//  TripTableCell.swift
//  TrailTracker
//
//  Created by Natasha Solanki on 4/16/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class TripTableCell: UITableViewCell {

    @IBOutlet weak var tripLabel: UILabel?
    @IBOutlet weak var participantsLabel: UILabel?
    
    @IBOutlet weak var staffLabel: UILabel?
    @IBOutlet weak var milesLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
