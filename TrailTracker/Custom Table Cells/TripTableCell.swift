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
    
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!

    @IBOutlet weak var distanceBadge: Badge!
    @IBOutlet weak var durationBadge: Badge!
    
    
    // Methods //
    
    func update(with trip: Trip) {
        
        tripLabel.attributedText = Font.make(text: "Super Awesome Tripperdoodle xxxafhaiufheihfaiehx", size: 30, color: Color.shade, type: .sunn)
        
        let participant_text = "\(trip.participant_count) Participant\(trip.participant_count == 1 ? "" : "s")"
        participantsLabel.attributedText = Font.make(text: participant_text, size: 23, color: Color.shade, type: .sunn)
        
        let staff_text = "\(trip.staff_count) Staff"
        staffLabel.attributedText = Font.make(text: staff_text, size: 23, color: Color.shade, type: .sunn)

        // Badges
        
        var distance_text: String!
        if let distance = trip.distance {
            distance_text = "\(CGFloat(distance).roundDigits(from: 1, to: 3))\(distance > 999 ? "+" : "") mi"
        } else {
            distance_text = "? mi"
        }
        distanceBadge.set(text: distance_text, backgroundColor: Color.green)
        
        var duration_text: String!
        if let time = trip.duration {
            duration_text = Date.deltaString(for: TimeInterval(time), display: .abbrv)
        } else {
            duration_text = "? min"
        }
        durationBadge.set(text: duration_text, backgroundColor: Color.red)
        
        
    }

}
