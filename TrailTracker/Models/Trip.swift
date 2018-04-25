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
    
    enum Field: String{
        case type = "type"
        case status = "status"
        case title = "title"
        case path = "path"
        case distance = "distance"
        case starttime = "starttime"
        case endtime = "endtime"
        case memberIds = "member_ids"
        case staffCount = "staff_count"
        case participantCount = "participant_count"
        case duration = "duration"
    }
    
    
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
    private(set) var distance: Double?
    private(set) var starttime: Date?
    private(set) var endtime: Date?             // ETA for in-progress trips, actual end time for complete trips
    
    private(set) var member_ids: [String]
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
    
    init(id: String, type: TripType, status: Status, title: String, member_ids: [String], staffCount: Int, participantCount: Int) {
        self.id = id
        self.type = type
        self.status = status
        self.title = title
        self.path = []
        self.member_ids = member_ids
        self.staff_count = staffCount
        self.participant_count = participantCount
    }
    
    init(type: TripType, status: Status, title: String, member_ids: [String], staffCount: Int, participantCount: Int) {
        self.id = IDField.none.rawValue
        self.type = type
        self.status = status
        self.title = title
        self.path = []
        self.member_ids = member_ids
        self.staff_count = staffCount
        self.participant_count = participantCount
    }
    
    private func setOptionalFields(distance: Double?, starttime: Date?, endtime: Date?){
        self.distance = distance
        self.starttime = starttime
        self.endtime = endtime
    }
    
    static func parse(json: ObjJSON) -> Trip? {
        return nil
    }
    
    func set(startTime: Date) {
        self.starttime = startTime
//        save()
    }
    
    func set(endTime: Date) {
        self.endtime = endTime
//        save()
    }
    
    func set(distance: Double) {
        self.distance = distance
//        save()
    }
    func set(path: [CLLocation]) {
        self.path = path
//        save()
    }
    
    func add(member_id: String, callback: @escaping StatusBlock) {
        self.member_ids.append(member_id)
        save()
        
        // Add trip id to the member
        var trip_ids = [String]()
        Utils.db.collection(Collection.members.rawValue).document(member_id)
        .addSnapshotListener{(documentSnapshot,error) in
            guard let document = documentSnapshot, error == nil else{
                debugPrint("Error getting document: \(String(describing: error))")
                callback(.error)
                return
            }
            let arr: HardJSON = document.data()!
            trip_ids = (arr[Member.Field.tripIds.rawValue] as? [String])!
            trip_ids.append(member_id)
            
            let ref = Utils.db.collection(Collection.members.rawValue).document(member_id)
            ref.setData([
                Member.Field.tripIds.rawValue: trip_ids
                ], options: SetOptions.merge())
            callback(.success)
        }
        
    }
    
    
    func removeMember(member_id: String) {
        if let ind = member_ids.index(of:member_id){
            self.member_ids.remove(at: ind)
        }
        save()
        let ref = Utils.db.collection(Collection.members.rawValue).document(member_id)
        ref.getDocument{(document,error) in
            if let data = document?.data(), var trip_ids = data[Member.Field.tripIds.rawValue]
                as? [String]{
                if let index = trip_ids.index(of: self.id) {
                    trip_ids.remove(at: index)
                    ref.updateData([Member.Field.tripIds.rawValue: trip_ids])
                }
            }
        }
    }
    
    // Remove Trip from database
    func remove(){
        
        var ref: DocumentReference!
        for mid in self.member_ids{
            ref = Utils.db.collection(Collection.members.rawValue).document(mid)
            ref.getDocument{(document, err) in
                let arr: HardJSON = document!.data()!
                var trip_ids = arr[Member.Field.tripIds.rawValue] as! [String]
                if let index = trip_ids.index(of: self.id) {
                    trip_ids.remove(at: index)
                    ref.updateData([Member.Field.tripIds.rawValue: trip_ids])
                }
            }
        }
        
        Utils.db.collection(Collection.trips.rawValue).document(self.id).delete(){ err in
            if let err = err {
                debugPrint("Error removing document: \(err)")
            } else {
                debugPrint("Document successfully removed!")
            }
        }
    }
    
    static func getTrip(trip_id: String, callback: @escaping TripBlock){
        Utils.db.collection(Collection.trips.rawValue).document(trip_id)
            .addSnapshotListener{(documentSnapshot, error) in
                guard let document = documentSnapshot, error == nil else {
                    debugPrint("Error getting document: \(String(describing: error))")
                    callback(.error,nil)
                    return
                }
                let id = document.documentID
                var arr: HardJSON = document.data()!
                guard
                    let type_raw = arr[Field.type.rawValue] as? String,
                    let type = Trip.TripType(rawValue: type_raw),
                    let status_raw = arr[Field.type.rawValue] as? String,
                    let status = Trip.Status(rawValue: status_raw),
                    let title = arr[Field.title.rawValue] as? String,
                    let g_path = arr[Field.path.rawValue] as? [GeoPoint],
                    let member_ids = arr[Field.memberIds.rawValue] as? [String],
                    let staff_count = arr[Field.staffCount.rawValue] as? Int,
                    let participant_count = arr[Field.participantCount.rawValue] as? Int
                    else{
                        debugPrint("Failed instantiating Trip object with data: \(arr)")
                        callback(.error,nil)
                        return
                    }
                let t = Trip(id: id, type: type, status: status, title: title, member_ids: member_ids, staffCount: staff_count, participantCount: participant_count)
                let path = Trip.Geo2CLArray(locs: g_path)
                let distance = arr[Field.distance.rawValue] as? Double
                let starttime = arr[Field.starttime.rawValue] as? Date
                let endtime = arr[Field.endtime.rawValue] as? Date
                t.setOptionalFields(distance: distance, starttime: starttime, endtime: endtime)
                t.set(path: path)
                callback(.success,t)
        }
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
        var ref: DocumentReference!
        if (self.id == IDField.none.rawValue){
            // Set Document ID before saving to Firestore
            ref = Utils.db.collection(Collection.trips.rawValue).document()
            self.id = ref.documentID
        } else {
            ref = Utils.db.collection(Collection.trips.rawValue).document(self.id)
        }
        
        let paths = Trip.CL2GeoArray(locs: self.path)
        ref.setData([
            Field.type.rawValue: self.type.rawValue,
            Field.status.rawValue : self.status.rawValue,
            Field.title.rawValue : self.title,
            Field.path.rawValue : paths,
            Field.memberIds.rawValue : self.member_ids,
            Field.staffCount.rawValue : self.staff_count,
            Field.participantCount.rawValue : self.participant_count,
            Field.distance.rawValue : self.distance as Any,
            Field.starttime.rawValue : self.starttime as Any,
            Field.endtime.rawValue : self.endtime as Any,
            Field.duration.rawValue : self.duration as Any
        ],options: SetOptions.merge())
    }

    // Get Methods //
    
    
    func getMembers(callback: @escaping MembersBlock){
        var members = [Member]()
        for mid in self.member_ids{
            Member.getMember(member_id: mid) { (status,member) in
                if status == .success, let member = member {
                    members.append(member)
                } else {
                    debugPrint("Trip \(mid) does not exist, Status: \(status)")
                    callback(.error,[])
                }
            }
        }
        callback(.success,members)
    }
    
    static func getTrips(callback: @escaping TripsBlock){
        Utils.db.collection(Collection.trips.rawValue).getDocuments {(querySnapshot,error) in
            guard let snapshot = querySnapshot, error == nil else {
                debugPrint("Error getting documents: \(String(describing: error))")
                callback(.error, [])
                return
            }
            
            var trips = [Trip]()
            for document in snapshot.documents{
                let id = document.documentID
                var arr: HardJSON = document.data()
                
                guard
                    let type_raw = arr[Field.type.rawValue] as? String,
                    let type = Trip.TripType(rawValue: type_raw),
                    let status_raw = arr[Field.status.rawValue] as? String,
                    let status = Trip.Status(rawValue: status_raw),
                    let title = arr[Field.title.rawValue] as? String,
                    let g_path = arr[Field.path.rawValue] as? [GeoPoint],
                    let member_ids = arr[Field.memberIds.rawValue] as? [String],
                    let staff_count = arr[Field.staffCount.rawValue] as? Int,
                    let participant_count = arr[Field.participantCount.rawValue] as? Int
                else{
                    debugPrint("Failed instantiating Trip object with data: \(arr)")
                    continue
                }
                let t = Trip(id: id, type: type, status: status, title: title, member_ids: member_ids, staffCount: staff_count, participantCount: participant_count)
                let distance = arr[Field.distance.rawValue] as? Double
                let starttime = arr[Field.starttime.rawValue] as? Date
                let endtime = arr[Field.endtime.rawValue] as? Date
                let path = Trip.Geo2CLArray(locs: g_path)
                t.setOptionalFields(distance: distance, starttime: starttime, endtime: endtime)
                t.set(path: path)
                trips.append(t)
            }
            callback(.success,trips)
        }
    }
}
