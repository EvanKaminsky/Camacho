//
//  Trip.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    private(set) var member_ids: Set<String>
    private(set) var staff_count: Int
    private(set) var participant_count: Int
    
    var duration: TimeInterval? {
        if let start = self.starttime {
            return endtime?.timeIntervalSince(start)
        } else {
            return nil
        }
    }
    
    var members: [Member] {
        return []
    }

    
    // Methods //
    
    init(id: String, type: TripType, status: Status, title: String, memberIDs: [String], staffCount: Int, participantCount: Int) {
        self.id = id
        self.type = type
        self.status = status
        self.title = title
        self.member_ids = Set(memberIDs)
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
    
    func add(memberID: String) {
        member_ids.insert(memberID)
    }
    
    func remove(memberID: String) {
        member_ids.remove(memberID)
    }
    
    
    // Spoof Data //
    
    static func spoofA() -> Trip {
        let trip = Trip(id: "tripA", type: .biking, status: .complete, title: "Trip 1", memberIDs: ["member1", "member2"], staffCount: 3, participantCount: 12)
        trip.set(distance: 4.8)
        trip.set(startTime: Date(iso8601: "2018-03-20T14:15:00 CST"))
        trip.set(endTime: Date(iso8601: "2018-03-20T14:41:00 CST"))
        return trip
    }
    
    
    
    
}
