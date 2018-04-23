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
        case activityIds = "activity_ids"
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
        self.path = []
        self.activity_ids = activity_ids
        self.staff_count = staffCount
        self.participant_count = participantCount
    }
    
    init(type: TripType, status: Status, title: String, activity_ids: [String], staffCount: Int, participantCount: Int) {
        self.id = "none"
        self.type = type
        self.status = status
        self.title = title
        self.path = []
        self.activity_ids = activity_ids
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
        let a = Activity(trip_id: self.id,member_id: member_id)
        self.activity_ids.append(a.id)
        save()
        
        // Add activity id to the member
        var activity_ids = [String]()
        Utils.db.collection(Collection.members.rawValue).document(member_id)
        .addSnapshotListener{(documentSnapshot,error) in
            guard let document = documentSnapshot, error == nil else{
                debugPrint("Error getting document: \(String(describing: error))")
                callback(.error)
                return
            }
            let arr: HardJSON = document.data()!
            activity_ids = (arr[Field.activityIds.rawValue] as? [String])!
            activity_ids.append(a.id)
        }
        let ref = Utils.db.collection(Collection.members.rawValue).document(member_id)
        ref.setData([
            Field.activityIds.rawValue: activity_ids
            ], options: SetOptions.merge())
        callback(.success)
    }
    
    func removeActivity(activity_id: String){
        if let ind = activity_ids.index(of:activity_id){
            self.activity_ids.remove(at: ind)
        }
        save()
    }
    
    func removeMember(memberID: String) {
        //query for Activity with member_id = memberID & trip_id = self.id
        var activity_id = String()
        Utils.db.collection(Collection.activites.rawValue)
            .whereField(IDField.tripID.rawValue, isEqualTo: self.id)
            .whereField(IDField.memberID.rawValue, isEqualTo: memberID)
            .getDocuments{(snapshot,error) in
                if let documents = snapshot?.documents{
                    for document in documents{
                        activity_id = document.documentID
                    }
                }
        }
        removeActivity(activity_id: activity_id)
        let ref = Utils.db.collection(Collection.members.rawValue).document(memberID)
        ref.getDocument{(document,error) in
            if let data = document?.data(), var activity_ids = data[IDField.activityIDs.rawValue]
                as? [String]{
                if let index = activity_ids.index(of: activity_id) {
                    activity_ids.remove(at: index)
                    ref.updateData([IDField.activityIDs.rawValue: activity_ids])
                }
            }
        }
        // Remove orphaned activity
        Utils.db.collection(Collection.activites.rawValue).document(activity_id).delete(){ err in
            if let err = err {
                debugPrint("Error removing document: \(err)")
            } else {
                debugPrint("Document successfully removed!")
            }
        }
    }
    
    // Remove Trip from database
    func remove(){
        
        // Remove this activity from any members
        var current_members = [Member]()
        Member.getMembers{(status,members) in
            if status == .error{
                debugPrint("Error getting member")
            }else{
                current_members = members
            }
        }
        for aid in self.activity_ids{
            for m in current_members{
                let cur_activities = m.getActivities()
                if cur_activities.contains(aid){
                    m.removeActivity(activity_id: aid)
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
                    let activity_ids = arr[Field.activityIds.rawValue] as? [String],
                    let staff_count = arr[Field.staffCount.rawValue] as? Int,
                    let participant_count = arr[Field.participantCount.rawValue] as? Int
                    else{
                        debugPrint("Failed instantiating Trip object with data: \(arr)")
                        callback(.error,nil)
                        return
                    }
                let t = Trip(id: id, type: type, status: status, title: title, activity_ids: activity_ids, staffCount: staff_count, participantCount: participant_count)
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
            Field.activityIds.rawValue : self.activity_ids,
            Field.staffCount.rawValue : self.staff_count,
            Field.participantCount.rawValue : self.participant_count,
            Field.distance.rawValue : self.distance as Any,
            Field.starttime.rawValue : self.starttime as Any,
            Field.endtime.rawValue : self.endtime as Any,
            Field.duration.rawValue : self.duration as Any
        ],options: SetOptions.merge())
    }

    // Get Methods //
    
    func getActivities() -> [String]{
        return self.activity_ids
    }
    
    func getMembers() -> [Member]{
        var members = [Member]()
        for aid in self.activity_ids{
            Utils.db.collection(Collection.activites.rawValue).document(aid).getDocument{(document,err) in
                if let err = err{
                    debugPrint("Error getting document: \(err)")
                }else{
                    var arr : HardJSON = document!.data()!
                    let member_id  = arr[IDField.memberID.rawValue] as? String
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
                    let activity_ids = arr[Field.activityIds.rawValue] as? [String],
                    let staff_count = arr[Field.staffCount.rawValue] as? Int,
                    let participant_count = arr[Field.participantCount.rawValue] as? Int
                else{
                    debugPrint("Failed instantiating Trip object with data: \(arr)")
                    continue
                }
                let t = Trip(id: id, type: type, status: status, title: title, activity_ids: activity_ids, staffCount: staff_count, participantCount: participant_count)
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
