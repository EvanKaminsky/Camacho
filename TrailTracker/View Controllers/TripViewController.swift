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

class TripViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    
    var trip = Trip.init(type: Trip.TripType(rawValue: "hiking")!, status: Trip.Status(rawValue: "new")!, title: "Test Run 1", activity_ids: ["1"], staffCount: 1, participantCount: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let locationManager = LocationManager.shared
//        locationManager.requestWhenInUseAuthorization()
        enableBasicLocationServices(locationManager: locationManager)
        
        //This ensures that location updates, a big battery consumer,
        //and the timer is stopped when the user navigates away from the view.
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        
        
        
        
        print(trip.title)
        stopButton.isHidden = true
        
        self.title = "Trip"
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        
        
    }
    
    @IBAction func startTapped(_ sender: Any) {
        print("Start button pressed")
        startRun()
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        print("Stop button pressed")
        let alertController = UIAlertController(title: "End run?",
                                                message: "Do you wish to end your run?",
                                                preferredStyle: .actionSheet)
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
        timer?.invalidate()
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }

    private func saveRun() {
        trip.set(distance: distance.value)
        trip.set(endTime: Date())
        trip.set(path: locationList)
        
        
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            locationList.append(newLocation)
        }
    }
}

