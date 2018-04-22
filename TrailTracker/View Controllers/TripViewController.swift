//
//  TripViewController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Trip"
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        
        
    }


    
    
}
