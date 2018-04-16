//
//  MemberTableCell.swift
//  TrailTracker
//
//  Created by Natasha Solanki on 4/16/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class MemberTableCell: UITableViewCell {

    @IBOutlet weak var userIconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tripsLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
