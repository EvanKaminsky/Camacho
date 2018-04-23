//
//  ParticipantViewController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

protocol getMemberInfoPrototcol {
    func getMemberInfo() -> Member
}

class ParticipantViewController: UIViewController {
    
    // Fields
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var guardianInfoLabel: UILabel!
    @IBOutlet weak var durationBadge: Badge!
    @IBOutlet weak var distanceBadge: Badge!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tripLabel: UILabel!
    
    var camachoButton: CamachoButton!
    
    var membersDelegate: getMemberInfoPrototcol?
    
    let refresher = UIRefreshControl()
    var trips: [Trip] = []
    var selectedRow: Int = -1
    

    // Methods //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let member = membersDelegate?.getMemberInfo() else {
            debugPrint("Error: Member not properly set before navigating to participant view controller!")
            return
        }
        
        self.title = member.full_name
        
        switch member.type {
        case .staff:
            icon.image = UIImage(named: "staff")?.withRenderingMode(.alwaysTemplate)
            participantLabel.attributedText = Font.make(text: "Staff", size: 40, color: Color.shade, type: .sunn)
        case .participant:
            icon.image = UIImage(named: "peep")?.withRenderingMode(.alwaysTemplate)
            participantLabel.attributedText = Font.make(text: "Participant", size: 40, color: Color.shade, type: .sunn)
        }
        icon.tintColor = Color.gray

        
        // Badges
        let duration_text = "\(member.total_distance.roundDigits(from: 1, to: 3))\(member.total_distance > 999 ? "+" : "") mi"
        durationBadge.set(text: duration_text, backgroundColor: Color.green)
        
        let distance_text = Date.deltaString(for: TimeInterval(member.total_duration), display: .abbrv)
        distanceBadge.set(text: distance_text, backgroundColor: Color.red)
        
        
        // Parent Information
        var parent_text = ""
        if let parent = member.guardian_name, !parent.isEmpty {
            parent_text += "Parent/Guardian • \(parent)"
        }
        if let email = member.guardian_email, !email.isEmpty {
            if !parent_text.isEmpty {
                parent_text += " • "
            }
            parent_text += email
        }
        if parent_text.isEmpty {
            guardianInfoLabel.alpha = 0
        } else {
            guardianInfoLabel.attributedText = Font.make(text: parent_text, size: 20, color: Color.shade, type: .paneuropa)
        }
        
        // Table
        tableView.register(TripTableCell.self, forCellReuseIdentifier: TripTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(ParticipantViewController.update), for: .valueChanged)
        tripLabel.attributedText = Font.make(text: "Trips (\(member.activity_ids.count))", size: 20, color: Color.white, type: .paneuropa)
        
        // Camacho Button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Add Trip", backgroundColor: Color.magenta)
        camachoButton.touchUpInside = { [weak self] button in
            button.bubble()
            self?.addTrip()
        }
        
        // Reshaping
        tripLabel.frame = CGRect(x: 0, y: tripLabel.frame.minY, width: self.view.width, height: tripLabel.height)
        tableView.frame = CGRect(x: 0, y: tripLabel.frame.maxY, width: self.view.width, height: self.view.height - tripLabel.frame.maxY)
        guardianInfoLabel.center.x = self.view.mid.x
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camachoButton.addToView()
        refresher.beginRefreshingManually(animated: false)
        self.update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camachoButton.removeFromSuperview()
    }
    

    @objc func update() {
        guard let _ = membersDelegate?.getMemberInfo() else {
            debugPrint("Error: Member not properly set when updating participant view controller!")
            return
        }
        
        self.trips = []
        refresher.endRefreshing()
    }
    
    func addTrip() {
        
        
    }
    
}


extension ParticipantViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TripTableCell.height
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let trip = trips[safe: indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TripTableCell.identifier, for: indexPath) as! TripTableCell
        cell.update(with: trip)
        return cell
    }
    
    
    // Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = trips[safe: indexPath.row] else {
            return
        }
        
        self.selectedRow = indexPath.row
        tableView.deselectSelectedRow()
        
        // TODO: Go to TripViewController, something like
        // self.startTrip(trip)
    }
    
}

