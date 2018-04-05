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
    private(set) var attendance_ids: Set<String>
    private(set) var total_distance: Double
    private(set) var total_duration: Double
    
//    var trips: [Trip] {
//        return []
//    }
    
    
    // Methods //
    
    init(id: String, type: MemberType, name: String, attendance_ids: [String], totalDistance: Double, totalDuration: Double) {
        self.id = id
        self.type = type
        self.full_name = name
        self.attendance_ids = Set(attendance_ids)
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
        let a = Attendance(id: "1234",trip_id: tripID, member_id: self.id)
        self.attendance_ids.insert(a.id)
    }
    
    func remove(tripID: String) {
        //qeuery for Attendance with trip_id = tripID and member_id = self.id
        self.attendance_ids.remove(tripID)
    }
    

    
    // Spoof Data //
    
    static func spoofA() -> Member {
        let member = Member(id: "member1", type: .staff, name: "Danny Quance", attendance_ids: ["attendance1"], totalDistance: 7.835, totalDuration: 2880)
        return member
    }
    
    static func spoofB() -> Member {
        let member = Member(id: "member2", type: .participant, name: "Brit McKyle", attendance_ids: ["attendance2"], totalDistance: 5.222, totalDuration: 2160)
        member.set(guardianName: "Lloyd McKyle")
        member.set(guardianEmail: "lloydswagger@gmail.com")
        return member
    }
    

    
    
    
}

