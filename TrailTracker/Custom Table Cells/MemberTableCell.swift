//
//  MemberTableCell.swift
//  TrailTracker
//
//  Created by Natasha Solanki on 4/16/18.
//  Copyright © 2018 Camacho. All rights reserved.
//s

import UIKit

class MemberTableCell: UITableViewCell {

    // Outlets //
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tripsBadge: Badge!
    @IBOutlet weak var milesBadge: Badge!
    @IBOutlet weak var timeBadge: Badge!
    
    static let height: CGFloat = 60
    static let identifier: String = "MemberTableViewCell"
    
        
    // Methods //
    
    func update(with member: Member) {
        switch member.type {
        case .staff:
            iconImage.image = UIImage(named: "staff")?.withRenderingMode(.alwaysTemplate)
        case .participant:
            iconImage.image = UIImage(named: "peep")?.withRenderingMode(.alwaysTemplate)
        }
        iconImage.tintColor = Color.gray
        
        nameLabel.attributedText = Font.make(text: member.full_name, size: 30, color: Color.shade, type: .sunn)
        
        // Badges
        
        let trip_text = "\(member.total_trips.roundDigits(from: 1, to: 3)) Trip\(member.total_trips == 1 ? "" : "s")"
        tripsBadge.set(text: trip_text, backgroundColor: Color.blue)
        
        let miles_text = "\(member.total_distance.roundDigits(from: 1, to: 3)) mi"
        milesBadge.set(text: miles_text, backgroundColor: Color.green)
        
        let time_text = Date.deltaString(for: TimeInterval(member.total_duration), display: .abbrv)
        timeBadge.set(text: time_text, backgroundColor: Color.red)
        

    }


}
