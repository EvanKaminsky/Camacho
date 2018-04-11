//
//  Activity.swift
//  TrailTracker
//
//  Created by Matthew on 4/4/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation


class Activity{
    
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
    init(trip_id: String, member_id: String) {
        self.id = "Activity1"
        self.trip_id = trip_id
        self.member_id = member_id
    }
    
    
    // Spoof Data //
    
    static func SpoofA() -> Activity{
        let activity = Activity(id:"activity1",trip_id: "tripA", member_id: "member1")
        return activity
    }
    
    static func SpoofB() -> Activity{
        let activity = Activity(id:"activity2",trip_id: "tripA", member_id: "member2")
        return activity
    }
}
