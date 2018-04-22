//
//  Trip.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Trip {
    
    // Fields //
    
    enum TripType: String {
        case hiking = "hiking"
        case biking = "biking"
        case kayaking = "kayaking"
    }
    
    enum Status: String {
        case new = "new"
        case inprogress = "in_progress"
        case complete = "complete"
    }
    
    private(set) var id: String
    private(set) var type: TripType
    private(set) var status: Status
    private(set) var title: String
    
    private(set) var path: [CLLocation] = []    // Array of locations representing the path of the trip
    private(set) var destination: CLLocation?   // Expected destination for in-progress trips, actual destination for complete trips
    private(set) var distance: Double?
    private(set) var starttime: Date?
    private(set) var endtime: Date?             // ETA for in-progress trips, actual end time for complete trips
    
    private(set) var activity_ids: [String]
    private(set) var staff_count: Int
    private(set) var participant_count: Int
    
    var duration: TimeInterval? {
        if let start = self.starttime {
            return endtime?.timeIntervalSince(start)
        } else {
            return nil
        }
    }
    
    
    // Methods //
    
    init(id: String, type: TripType, status: Status, title: String, activity_ids: [String], staffCount: Int, participantCount: Int) {
        self.id = id
        self.type = type
        self.status = status
        self.title = title
        self.activity_ids = activity_ids
        self.staff_count = staffCount
        self.participant_count = participantCount
    }
    init(type: TripType, status: Status, title: String, activity_ids: [String], staffCount: Int, participantCount: Int) {
        self.id = "none"
        self.type = type
        self.status = status
        self.title = title
        self.activity_ids = activity_ids
        self.staff_count = staffCount
        self.participant_count = participantCount
    }
    
    static func parse(json: ObjJSON) -> Trip? {
        return nil
    }
    
    func set(startTime: Date) {
        self.starttime = startTime
    }
    
    func set(endTime: Date) {
        self.endtime = endTime
    }
    
    func set(distance: Double) {
        self.distance = distance
    }
    func set(destination: CLLocation) {
        self.destination = destination
    }
    func set(path: [CLLocation]) {
        self.path = path
    }
    
    func add(member_id: String) {
        let a = Activity(trip_id: self.id,member_id: member_id)
        activity_ids.append(a.id)
    }
    
    func remove(memberID: String) {
        //query for Activity with member_id = memberID & trip_id = self.id
        var activity_id = String()
        Utils.db.collection("activities").whereField("trip_id", isEqualTo: self.id).whereField("member_id", isEqualTo: memberID).getDocuments{(snapshot,error) in
            for document in (snapshot?.documents)!{
                activity_id = document.documentID
            }
        }
        let ind = activity_ids.index(of:activity_id)
        self.activity_ids.remove(at: ind!)
        save()
        let ref = Utils.db.collection("members").document(memberID)
        ref.getDocument{(document,error) in
            if var a_ids = document?.data()!["activity_ids"] as? Array<String>{
                let i = a_ids.index(of: activity_id)
                a_ids.remove(at: i!)
                ref.updateData(["activity_ids": a_ids])
            }
        }
        // Remove orphaned activity
        Utils.db.collection("activities").document(activity_id).delete(){ err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    static func getTrip(trip_id: String) -> Trip {
        var t2 = [Trip]() //This is really bad but temporary until asynchronous
        Utils.db.collection("trips").document(trip_id).getDocument{(document, err) in
            if let err = err{
                debugPrint("Error getting document: \(err)")
            }else{
                let id = document!.documentID
                var arr : HardJSON = document!.data()!
                let type = arr["type"] as? String
                let status = arr["status"] as? String
                let title = arr["title"] as? String
                let path = arr["path"] as? [GeoPoint]
                let destination = arr["destination"] as? GeoPoint
                let distance = arr["distance"] as? Double
                let starttime = arr["starttime"] as? Date
                let endtime = arr["endtime"] as? Date
                let activity_ids = arr["activity_ids"] as? [String]
                let staff_count = arr["staff_count"] as? Int
                let participant_count = arr["participant_count"] as? Int
                let t = Trip(id: id, type: Trip.TripType(rawValue: type!)!, status: Trip.Status(rawValue: status!)!, title: title!, activity_ids: activity_ids!, staffCount: staff_count!, participantCount: participant_count!)
                t.set(endTime: endtime!)
                t.set(startTime: starttime!)
                t.set(distance: distance!)
                let dest = Trip.Geo2CL(gp: destination!)
                t.set(destination: dest)
                let paths = Trip.Geo2CLArray(locs: path!)
                t.set(path: paths)
                t2.append(t)
            }
        }
        return t2[0]
    }
    
    func getMembers() -> [Member]{
        var members = [Member]()
        for aid in self.activity_ids{
            Utils.db.collection("activities").document(aid).getDocument{(document,err) in
                if let err = err{
                    debugPrint("Error getting document: \(err)")
                }else{
                    var arr : [String: Any] = document!.data()!
                    let member_id  = arr["member_id"] as? String
                    Member.getMember(member_id: member_id!) { (status, member) in
                        if status == .error{
                            debugPrint("Member does not Exist: \(status)")
                        }else{
                            members.append(member!)
                        }
                    }
                }
            }
        }
        return members
    }
    
    
    static func CL2Geo(loc: CLLocation) -> GeoPoint {
        let coord = loc.coordinate
        let dest = GeoPoint(latitude: coord.latitude,longitude: coord.longitude)
        return dest
    }
    
    static func CL2GeoArray(locs: [CLLocation]) -> [GeoPoint]{
        var points = [GeoPoint]()
        for loc in locs{
            let gp = CL2Geo(loc: loc)
            points.append(gp)
        }
        return points
    }
    
    static func Geo2CL(gp: GeoPoint) -> CLLocation{
        let loc = CLLocation(latitude: gp.latitude,longitude: gp.longitude)
        return loc
    }
    
    static func Geo2CLArray(locs: [GeoPoint]) -> [CLLocation]{
        var points = [CLLocation]()
        for gp in locs{
            let loc = Geo2CL(gp: gp)
            points.append(loc)
        }
        return points
    }
    
    func save(){
        let dest = Trip.CL2Geo(loc: self.destination!)
        let paths = Trip.CL2GeoArray(locs: self.path)
        if(self.id == "none"){
            save2()
        }else{
        let ref = Utils.db.collection("trips").document(self.id)
            ref.setData([
                "type" : self.type.rawValue,
                "status" : self.status.rawValue,
                "title" : self.title,
                "path" : paths,
                "activity_ids" : self.activity_ids,
                "staff_count" : self.staff_count,
                "participant_count" : self.participant_count,
                "destination" : dest,
                "distance" : self.distance as Any,
                "starttime" : self.starttime as Any,
                "endtime" : self.endtime as Any,
                "duration" : self.duration as Any
            ],options: SetOptions.merge()){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    // Generate ID before saving to Firestore
    func save2(){
        let dest = Trip.CL2Geo(loc: self.destination!)
        let paths = Trip.CL2GeoArray(locs: self.path)
        let ref = Utils.db.collection("trips").document()
        self.id = ref.documentID
        ref.setData([
            "type" : self.type.rawValue,
            "status" : self.status.rawValue,
            "title" : self.title,
            "path" : paths,
            "activity_ids" : self.activity_ids,
            "staff_count" : self.staff_count as Any,
            "participant_count" : self.participant_count,
            "destination" : dest,
            "distance" : self.distance as Any,
            "starttime" : self.starttime as Any,
            "endtime" : self.endtime as Any,
            "duration" : self.duration as Any
        ],options: SetOptions.merge()){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    static func getTrips() -> [Trip]{
        print("Getting Trips")
        var trips = [Trip]()
        Utils.db.collection("trips").getDocuments{(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    var arr : [String: Any] = document.data()
                    let type = arr["type"] as? String
                    let status = arr["status"] as? String
                    let title = arr["title"] as? String
                    let path = arr["path"] as? [GeoPoint] //Change this to doubles later
                    let destination = arr["destination"] as? GeoPoint
                    let distance = arr["distance"] as? Double
                    let starttime = arr["starttime"] as? Date
                    let endtime = arr["endtime"] as? Date
                    let activity_ids = arr["activity_ids"] as? [String]
                    let staff_count = arr["staff_count"] as? Int
                    let participant_count = arr["participant_count"] as? Int
                    let t = Trip(id: id, type: Trip.TripType(rawValue: type!)!, status: Trip.Status(rawValue: status!)!, title: title!, activity_ids: activity_ids!, staffCount: staff_count!, participantCount: participant_count!)
                    t.set(endTime: endtime!)
                    t.set(startTime: starttime!)
                    t.set(distance: distance!)
                    let dest = Trip.Geo2CL(gp: destination!)
                    t.set(destination: dest)
                    let paths = Trip.Geo2CLArray(locs: path!)
                    t.set(path: paths)
                    trips.append(t)
                }
            }
        }
        return trips
    }
    
    
    
}
