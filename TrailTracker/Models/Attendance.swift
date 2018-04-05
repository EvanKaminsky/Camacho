//
//  Attendance.swift
//  TrailTracker
//
//  Created by Matthew on 4/4/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation


class Attendance{
    
    // Fields //
    
    private(set) var id: String
    private(set) var trip_id: String
    private(set) var member_id: String
    
    // Methods //
    
    init(id: String, trip_id: String, member_id: String) {
        self.id = id
        self.trip_id = trip_id
        self.member_id = member_id
    }
    
    
    // Spoof Data //
    
    static func SpoofA() -> Attendance{
        let attendance = Attendance(id:"attendance1",trip_id: "tripA", member_id: "member1")
        return attendance
    }
    
    static func SpoofB() -> Attendance{
        let attendance = Attendance(id:"attendance2",trip_id: "tripA", member_id: "member2")
        return attendance
    }
}

