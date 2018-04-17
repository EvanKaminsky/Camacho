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
        // self.id = "Activity\(Activity.count)"
        // Activity.count+=1
        self.id = "none"
        self.trip_id = trip_id
        self.member_id = member_id
    }
    
    
    // Networking
    
    func save(){
        if (self.id == IDField.none.rawValue) {
            save2()
            return
        }
        
        let ref = Utils.db.collection(Collection.trips.rawValue).document(self.id)
        ref.setData([
            IDField.tripID.rawValue: self.trip_id,
            IDField.memberID.rawValue: self.member_id
        ],options: SetOptions.merge())
    }
    
    // Creates ID before saving to Firestore and keeps it
    func save2(){
        let ref = Utils.db.collection(Collection.trips.rawValue).document()
        self.id = ref.documentID
        ref.setData([
            IDField.tripID.rawValue: self.trip_id,
            IDField.memberID.rawValue: self.member_id
        ],options: SetOptions.merge())
    }
    
}





