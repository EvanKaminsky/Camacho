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
    
    @IBOutlet weak var backgroundView: UIView!
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
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Asking for permissions like a nice person
        enableBasicLocationServices(locationManager: locationManager)
        
        //mapview setup to show user location
        mapView.delegate = self
        backgroundView.backgroundColor = Color.black
        
        //This ensures that location updates, a big battery consumer,
        //and the timer is stopped when the user navigates away from the view.
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        
        // Checking to see if this is a Start Trip or view completed trip
        if isStart {
            mapView.showsUserLocation = true
            mapView.mapType = MKMapType(rawValue: 0)!
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        }
        else {
            self.trip = (tripDelegate?.getTripInfo())!
            print(trip.title)
            print(trip.distance)
            configureView()
        }
        

        
        self.title = "Trip"
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        //camacho button
        createCamachoButton(buttonText: "Start")
  
    }
    
    func createCamachoButton(buttonText: String) {
        let button_width = 0.2 * view.width
        if buttonText == "Start" { //Start button
            camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: buttonText, backgroundColor: Color.forest)
            camachoButton.addToView()
            camachoButton.addTarget(self, action: #selector(pressedCamachoStartButton), for: .touchUpInside)
        }
        else { // End button
            camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: buttonText, backgroundColor: Color.red)
            camachoButton.addToView()
            camachoButton.addTarget(self, action: #selector(pressedCamachoStopButton), for: .touchUpInside)
        }
    }
    
    @objc func pressedCamachoStartButton () {
        print("CamachoStartButton was pressed!")
        startRun()
        camachoButton.removeFromSuperview()
        createCamachoButton(buttonText: "End")
    }
    
    @objc func pressedCamachoStopButton () {
        print("CamachoStopButton was pressed!")
        self.camachoButton.removeFromSuperview()
        let alertController = UIAlertController(title: "End run?",
                                                message: "Do you wish to end your run?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.createCamachoButton(buttonText: "End")
        })
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.saveRun()
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.stopRun()
            self.createCamachoButton(buttonText: "Start")
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
        trip.set(startTime: Date())
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
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        // Clear display values
        self.clearFields()
        
        // Go back to previous screen???
    }
    
    private func clearFields () {
        distanceLabel.text = "Distance"
        dateLabel.text = "Date"
        timeLabel.text = "Time"
        paceLabel.text = "Pace"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func saveRun() {
        print("Saving Trip")
        // Stopping trip
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        
        let distanceInMiles = distance.converted(to: .miles)
        trip.set(distance: Double(distanceInMiles.value))
        trip.set(endTime: Date())
        trip.set(path: locationList)
        
        
        // Save Trip
        trip.save()
        configureView()
    }
    
    
    
    // Completed Run view
    private func configureView() {
        let distance = Measurement(value: trip.distance!, unit: UnitLength.miles)
        print("duration: ")
//        print(trip.duration)
        let seconds = Int(trip.duration!)
        let formattedDistance = FormatDisplay.distance(distance.converted(to: .meters))
        let formattedDate = FormatDisplay.date(trip.endtime)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time:  \(formattedTime)"
        paceLabel.text = "Pace:  \(formattedPace)"
        
        loadMap()
    }
    
    
    // An MKCoordinateRegion represents the display region for the map.
    // You define it by supplying a center point and a span that defines horizontal and vertical ranges.
    private func mapRegion() -> MKCoordinateRegion? {
        let locations = trip.path
        if locations.count < 1 {
            return nil
        }
        let latitudes = locations.map { location -> Double in
            return location.coordinate.latitude
        }
        
        let longitudes = locations.map { location -> Double in
            return location.coordinate.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // Here, you turn each recorded location from the run into a CLLocationCoordinate2D as required by MKPolyline.
    private func polyLine() -> MKPolyline {
        let locations = trip.path
        
        if locations.count < 1 {
            return MKPolyline()
        }
        
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    // Here, you make sure there is something to draw. Then you set the map region and add the overlay.
    private func loadMap() {
        let locations = trip.path
        let region = mapRegion()
        if locations.count < 1 {
            let alert = UIAlertController(title: "Error",
                                          message: "Sorry, this run has no locations saved",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        mapView.setRegion(region!, animated: true)
        mapView.add(polyLine())
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

