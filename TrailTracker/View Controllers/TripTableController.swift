//
//  TripTableController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit
import CoreLocation

class TripTableController: UIViewController, getTripInfoPrototcol {
    
    // Fields //
    
    @IBOutlet weak var tableView: UITableView!

    var camachoButton: CamachoButton!
    
    let refresher = UIRefreshControl()
    var trips: [Trip] = []
    var selectedRow: Int = -1
    
    
    // Methods //
    
    // Needed for mapView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav Bar
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        // Table
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(TripTableController.update), for: .valueChanged)
     
        // Camacho Button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Start", backgroundColor: Color.forest)
        camachoButton.touchUpInside = { [weak self] button in
            button.bubble()
            self?.startTrip()
        }
        
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
        camachoButton.addToView()
        if self.trips.isEmpty || SHOULD_RELOAD_TRIPS {
            refresher.beginRefreshingManually(animated: false)
            self.update()
            SHOULD_RELOAD_TRIPS = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camachoButton.removeFromSuperview()
    }
    
    @objc func update() {
        Trip.getTrips { [weak self] (status, trips) in
            DispatchQueue.main.async {
                self?.refresher.endRefreshing()
                if status == .success {
                    self?.trips = trips
                    self?.tableView.reloadData()
                }
            }
        }
    }

    
    func startTrip() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TripViewController") as! TripViewController

        vc.trip = Trip.init(type: Trip.TripType(rawValue: "hiking")!, status: Trip.Status(rawValue: "new")!, title: "Test Run From View Controller!", activity_ids: ["1"], staffCount: 1, participantCount: 1)
        vc.isStart = true
        
        // Open MapView ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripSegue",
            let destination = segue.destination as? TripViewController
        {
            destination.tripDelegate = self
        }
        
    }
    
    func getTripInfo() -> Trip {
        return trips[self.selectedRow]
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
        tableView.deselectSelectedRow()
        self.selectedRow = indexPath.row
        // TODO: Go to TripViewController, something like
        // self.startTrip(trip)
    }
    
}









