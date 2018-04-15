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
    
    private(set) var activity_ids: Array<String>
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
        
    }
    
    func save(){
        let db = Utils.db
        let ref = db.collection("trips").document(self.id)
        ref.setData([
            "type" : self.type.rawValue,
            "status" : self.status.rawValue,
            "title" : self.title,
            "path" : self.path,
            "activitiy_ids" : self.activity_ids,
            "staff_count" : self.staff_count,
            "participant_count" : self.participant_count,
            "destination" : self.destination,
            "distance" : self.distance,
            "starttime" : self.starttime,
            "endtime" : self.endtime,
            "duration" : self.duration
        ],options: SetOptions.merge()){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }

        // Check for null values in optionals, convert to NSNull type, probably don't need these

//        if self.destination == nil {
//            ref.setData(["destination" : NSNull()],options: SetOptions.merge())
//        }
//        else{
//            ref.setData(["destination" : self.destination],options: SetOptions.merge())
//        }
//        if self.distance == nil {
//            ref.setData(["distance" : NSNull()],options: SetOptions.merge())
//        }
//        else{
//            ref.setData(["distance" : self.destination],options: SetOptions.merge())
//        }
//        if self.starttime == nil {
//            ref.setData(["starttime" : NSNull()],options: SetOptions.merge())
//        }
//        else{
//            ref.setData(["starttime" : self.starttime],options: SetOptions.merge())
//        }
//        if self.endtime == nil {
//            ref.setData(["endtime" : NSNull()],options: SetOptions.merge())
//        }
//        else{
//            ref.setData(["endtime" : self.endtime],options: SetOptions.merge())
//        }
//        if self.duration == nil {
//            ref.setData(["duration" : NSNull()],options: SetOptions.merge())
//        }
//        else{
//            ref.setData(["duration" : self.duration],options: SetOptions.merge())
//        }
    }
    
    // Spoof Data //
    
    static func spoofA() -> Trip {
        let trip = Trip(id: "tripA", type: .biking, status: .complete, title: "Trip 1", activity_ids: ["activity1", "activity2"], staffCount: 3, participantCount: 12)
        trip.set(distance: 4.8)
        trip.set(startTime: Date(iso8601: "2018-03-20T14:15:00 CST"))
        trip.set(endTime: Date(iso8601: "2018-03-20T14:41:00 CST"))
        return trip
    }
    
    
    
    
}
