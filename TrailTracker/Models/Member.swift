//
//  Member.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import Firebase

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
    private(set) var activity_ids: Array<String>
    private(set) var total_distance: Double
    private(set) var total_duration: Double
    
    
    // Methods //
    
    init(id: String, type: MemberType, name: String, activity_ids: [String], totalDistance: Double, totalDuration: Double) {
        self.id = id
        self.type = type
        self.full_name = name
        self.activity_ids = activity_ids
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
        self.activity_ids.append(a.id)
    }
    
    func remove(tripID: String) {
        var activity_id = String()
        Utils.db.collection("activities").whereField("trip_id", isEqualTo: tripID).whereField("member_id", isEqualTo: self.id).getDocuments{(snapshot,error) in
            for document in (snapshot?.documents)!{
                activity_id = document.documentID
            }
        }
        let ind = activity_ids.index(of:activity_id)
        self.activity_ids.remove(at: ind!)
        save()
        let ref = Utils.db.collection("trips").document(tripID)
        ref.getDocument{(document,error) in
            if var a_ids = document?.data()!["activity_ids"] as? Array<String>{
                let i = a_ids.index(of: activity_id)
                a_ids.remove(at: i!)
                ref.updateData(["activity_ids": a_ids])
            }
        }
        
    }
    
    func save(){
        let ref = Utils.db.collection("Members").document(self.id)
        ref.setData([
            "type" : self.type.rawValue,
            "full_name" : self.full_name,
            "guardian_name" : self.guardian_name,
            "guardian_email" : self.guardian_email,
            "activitiy_ids" : self.activity_ids,
            "total_distance" : self.total_distance,
            "total_duration" : self.total_duration
            ],options: SetOptions.merge())
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

