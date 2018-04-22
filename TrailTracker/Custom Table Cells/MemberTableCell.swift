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
    @IBOutlet weak var tripsBadge: UIView!
    @IBOutlet weak var milesBadge: UIView!
    @IBOutlet weak var timeBadge: UIView!
    
    
    
        
    // Methods //
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with member: Member) {
        switch member.type {
        case .staff:
            iconImage.image = UIImage(named: "staff")?.withRenderingMode(.alwaysTemplate)
        case .participant:
            iconImage.image = UIImage(named: "peep")?.withRenderingMode(.alwaysTemplate)
        }
        iconImage.tintColor = Color.gray
        
        nameLabel.attributedText = Font.make(text: member.full_name, size: 30, color: Color.shade, type: .sunn)
        
        //tripsLabel.attributedText = Font.make(text: String(member.activity_ids.count), size: 15, color: Color.white, type: .paneuropa)
        //milesLabel.attributedText = Font.make(text: String(member.total_distance), size: 15, color: Color.white, type: .paneuropa)
        //.timeLabel.attributedText = Font.make(text: String(member.total_distance), size: 15, color: Color.white, type: .paneuropa)
    }


}
