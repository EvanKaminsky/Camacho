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
    
    // Fields //
    
    @IBOutlet weak var tableView: UITableView!

    let refresher = UIRefreshControl()
    var trips: [Trip] = []
    
    
    
    // Methods //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(TripTableController.update), for: .valueChanged)
        
        // Test Camacho Button (TODO: Put in front of toolbar)
        let button_width = 0.2 * view.width
        let button = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Start", backgroundColor: Color.forest)
        button.center = CGPoint(x: 0.5 * view.width, y: 0.85 * view.height)
        button.touchUpInside = { [weak self] button in
            button.bubble()
            self?.startTrip()
        }
        self.view.addSubview(button)
        
        // Test Badges (TODO: Add to table cells and overlay mapview in the TripViewController)
        //let badge_1 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "3 Trips", backgroundColor: Color.blue)
        //let badge_2 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "28.1 mi.", backgroundColor: Color.green)
        //let badge_3 = Badge(frame: CGRect(x: 0, y: 0, width: badge_width, height: badge_height), text: "36 min", backgroundColor: Color.red)

        
        // Test Member Type Button
        // let member_button_1 = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Staff", image: "staff", isSelected: true, themeColor: Color.orange)
        // member_button_1.center = CGPoint(x: 0.7 * view.width, y: 0.15 * view.height)
        // member_button_1.touchUpInside = { button in
        //     button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
        //     member_button_1.toggleSelected()
        // }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.trips.isEmpty {
            refresher.beginRefreshingManually(animated: false)
            self.update()
        }
    }
    
    @objc func update() {
        async(after: 1.3) { [weak self] in
            self?.refresher.endRefreshing()
        }
        
        /*
        Trip.getTrips { [weak self] (status, trips) in
            DispatchQueue.main.async {
                self?.refresher.endRefreshing()
                if status == .success {
                    self?.participants = members
                    self?.tableView.reloadData()
                }
            }
        }
        */
    }

    
    func startTrip() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}


extension TripTableController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let trip = trips[safe: indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripTableCell", for: indexPath) as! TripTableCell
        cell.update(with: trip)
        return cell
    }
    
    
    // Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = trips[safe: indexPath.row] else {
            return
        }
        
        // TODO: Go to TripViewController, something like
        // self.startTrip(trip)
    }
    
}









