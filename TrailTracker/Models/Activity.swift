//
//  Activity.swift
//  TrailTracker
//
//  Created by Matthew on 4/4/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import Firebase

class Activity{
    
    // Fields //
    
    private(set) var id: String
    private(set) var trip_id: String
    private(set) var member_id: String
    static var count: Int = 1
    // Methods //
    
    init(id: String, trip_id: String, member_id: String) {
        self.id = id
        self.trip_id = trip_id
        self.member_id = member_id
    }
    init(trip_id: String, member_id: String) {
//        self.id = "Activity\(Activity.count)"
//        Activity.count+=1
        self.id = "none"
        self.trip_id = trip_id
        self.member_id = member_id
    }
    
    func save(){
        if(self.id == "none"){
            save2()
        }
        else{
            let ref = Utils.db.collection("trips").document(self.id)
            ref.setData([
                "trip_id" : self.trip_id,
                "member_id" : self.member_id
                ],options: SetOptions.merge())
        }
    }
    
//    Creates ID before saving to Firestore and keeps it 
    func save2(){
        let ref = Utils.db.collection("trips").document()
        self.id = ref.documentID
        ref.setData([
            "trip_id" : self.trip_id,
            "member_id" : self.member_id
            ],options: SetOptions.merge())
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

