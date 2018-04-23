//
//  TripViewController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol getTripInfoPrototcol {
    func getTripInfo() -> Trip
}

class TripViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var camachoButton: CamachoButton!
    var camanchoEndButton: CamachoButton!
    
    var tripDelegate: getTripInfoPrototcol?
    var isStart: Bool = false
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    
    var trip = Trip.init(type: Trip.TripType(rawValue: "hiking")!, status: Trip.Status(rawValue: "new")!, title: "Test Run 1", activity_ids: ["1"], staffCount: 1, participantCount: 1)
    
    // Methods //
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Asking for permissions like a nice person
        enableBasicLocationServices(locationManager: locationManager)
        
        //mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        //This ensures that location updates, a big battery consumer,
        //and the timer is stopped when the user navigates away from the view.
        timer?.invalidate()
        locationManager.stopUpdatingLocation()

        stopButton.isHidden = true
        
        self.title = "Trip"
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        // Camacho button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Start", backgroundColor: Color.forest)
        camachoButton.touchUpInside = { button in
            button.bubble()
            
            self.camanchoEndButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "End", backgroundColor: Color.red)
            self.camanchoEndButton.addToView()
            self.startRun()
            self.camanchoEndButton.touchUpInside = { button in
                button.bubble()
                // add functionalith to end trip
            }
        }
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camachoButton.addToView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camachoButton.removeFromSuperview()
    }

    @IBAction func startTapped(_ sender: Any) {
        print("Start button pressed")
        startRun()
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        print("Stop button pressed")
        let alertController = UIAlertController(title: "End run?", message: "Do you wish to end your run?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.stopRun()
            self.saveRun()
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.stopRun()
        })
        present(alertController, animated: true)
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        distanceLabel.text = "Distance:  \(formattedDistance)"
        timeLabel.text = "Time:  \(formattedTime)"
        paceLabel.text = "Pace:  \(formattedPace)"
    }

    private func startRun() {
        startButton.isHidden = true
        stopButton.isHidden = false
        trip.set(startTime: Date())
//        trip.set(status: status)
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        
    }
    
   
    private func stopRun() {
        startButton.isHidden = false
        stopButton.isHidden = true
        locationManager.stopUpdatingLocation()
//        timer?.invalidate()
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func saveRun() {
        let distanceInMiles = distance.converted(to: .miles)
        trip.set(distance: distanceInMiles.value)
        trip.set(endTime: Date())
        trip.set(path: locationList)
        
        SHOULD_RELOAD_TRIPS = true
        
        // Save Trip
        trip.save()
    }
    
}

extension TripViewController: CLLocationManagerDelegate {
    func enableBasicLocationServices(locationManager: CLLocationManager) {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //            disableMyLocationBasedFeatures()
            print(".restricted, .denied")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            //            enableMyWhenInUseFeatures()
            print("authorizedWhenInUse, .authorizedAlways")
            break
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        //drawing path or route covered
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            var polyline = MKPolyline(coordinates: area, count: area.count)
            mapView.add(polyline)
            print("getting new location!!")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            print("appending new location to locationlist")
            if locationList.count > 0 {
                let area = [locationList[locationList.count - 1].coordinate, newLocation.coordinate]
                let polyline = MKPolyline(coordinates: area, count: area.count)
                mapView.add(polyline)
                print("getting new location!!")
            }
            
            locationList.append(newLocation)
        }
    }
}

extension TripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            print("in mapView function about to return PR")
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.red
            pr.lineWidth = 5
            return pr
        }
        print("Going to return nil as the overlay")
        return nil
    }
}

