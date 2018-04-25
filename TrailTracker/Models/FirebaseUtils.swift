//
//  FirebaseUtils.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/24/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation


enum NetworkingStatus {
    case success
    case error
}

enum Collection: String {
    case activites = "activities"
    case members   = "members"
    case trips     = "trips"
}

enum IDField: String {
    case tripID      = "trip_id"
    case memberID    = "member_id"
    case activityIDs = "activity_ids"
    case none        = "none"
}


class FirebaseUtils {
    
    // Snapshot & Error Unwrappers //
    
    static func unwrap(snapshot: DocumentSnapshot?, error: Error?) -> DocumentSnapshot? {
        if let document = snapshot, error == nil {
            return document
        } else {
            debugPrint("Error getting document: \(String(describing: error))")
            return nil
        }
    }
    
    static func unwrap(snapshot: QuerySnapshot?, error: Error?) -> QuerySnapshot? {
        if let query = snapshot, error == nil {
            return query
        } else {
            debugPrint("Error getting query: \(String(describing: error))")
            return nil
        }
    }
    
    // Location Utilities //
    
    static func CL2Geo(loc: CLLocation) -> GeoPoint {
        let coord = loc.coordinate
        let dest = GeoPoint(latitude: coord.latitude,longitude: coord.longitude)
        return dest
    }
    
    static func CL2GeoArray(locs: [CLLocation]) -> [GeoPoint] {
        var points = [GeoPoint]()
        for loc in locs{
            let gp = CL2Geo(loc: loc)
            points.append(gp)
        }
        return points
    }
    
    static func Geo2CL(gp: GeoPoint) -> CLLocation {
        let loc = CLLocation(latitude: gp.latitude, longitude: gp.longitude)
        return loc
    }
    
    static func Geo2CLArray(locs: [GeoPoint]) -> [CLLocation] {
        var points = [CLLocation]()
        for gp in locs{
            let loc = Geo2CL(gp: gp)
            points.append(loc)
        }
        return points
    }
    
    
}
