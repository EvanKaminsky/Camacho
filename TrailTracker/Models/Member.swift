//
//  Member.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation

class Member {
    
    // Fields //
    
    enum MemberType: String {
        case staff = "Staff"
        case participant = "Participant"
    }
    
    private(set) var id: String
    private(set) var type: MemberType
    private(set) var full_name: String
    private(set) var guardian_name: String?
    private(set) var guardian_email: String?
    
//    private(set) var trip_ids: Set<String>
    private(set) var activity_ids: Set<String>
    private(set) var total_distance: Double
    private(set) var total_duration: Double
    
    
    // Methods //
    
    init(id: String, type: MemberType, name: String, activity_ids: [String], totalDistance: Double, totalDuration: Double) {
        self.id = id
        self.type = type
        self.full_name = name
        self.activity_ids = Set(activity_ids)
        self.total_distance = totalDistance
        self.total_duration = totalDuration
    }
    
    static func parse(json: ObjJSON) -> Member? {
        return nil
    }
    
    func set(name: String) {
        self.full_name = name
    }
    
    func set(guardianName: String) {
        self.guardian_name = guardianName
    }
    
    func set(guardianEmail: String) {
        self.guardian_email = guardianEmail
    }
    
    func add(tripID: String) {
        // Generate ID
        let a = Activity(trip_id: tripID, member_id: self.id)
        self.activity_ids.insert(a.id)
    }
    
    func remove(tripID: String) {
        //qeuery for Activity with trip_id = tripID and member_id = self.id
        self.activity_ids.remove(tripID)
    }
    func save(){
        let ref = Utils.db.collection("Members").document(self.id)
        ref.updateData([
            "type" : self.type,
            "full_name" : self.full_name,
            "guardian_name" : self.guardian_name,
            "guardian_email" : self.guardian_email,
            "activitiy_ids" : self.activity_ids,
            "total_distance" : self.total_distance,
            "total_duration" : self.total_duration
            ])
    }
    

    
    // Spoof Data //
    
    static func spoofA() -> Member {
        let member = Member(id: "member1", type: .staff, name: "Danny Quance", activity_ids: ["activity1"], totalDistance: 7.835, totalDuration: 2880)
        return member
    }
    
    static func spoofB() -> Member {
        let member = Member(id: "member2", type: .participant, name: "Brit McKyle", activity_ids: ["activity2"], totalDistance: 5.222, totalDuration: 2160)
        member.set(guardianName: "Lloyd McKyle")
        member.set(guardianEmail: "lloydswagger@gmail.com")
        return member
    }
    

    
    
    
}

