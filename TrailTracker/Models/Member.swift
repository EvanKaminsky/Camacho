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
    
    enum Field: String {
        case type = "type"
        case fullName = "full_name"
        case guardianName = "guardian_name"
        case guardianEmail = "guardian_email"
        case activityIds = "activity_ids"
        case totalDistance = "total_distance"
        case totalDuration = "total_duration"
    }
    
    enum MemberType: String {
        case staff = "Staff"
        case participant = "Participant"
    }
        
    private(set) var id: String
    private(set) var type: MemberType
    private(set) var full_name: String
    private(set) var guardian_name: String?
    private(set) var guardian_email: String?
    
    private(set) var activity_ids: Array<String>
    private(set) var total_distance: Double
    private(set) var total_duration: Double
    
    init(id: String, type: MemberType, name: String, activity_ids: [String], totalDistance: Double, totalDuration: Double) {
        self.id = id
        self.type = type
        self.full_name = name
        self.activity_ids = activity_ids
        self.total_distance = totalDistance
        self.total_duration = totalDuration
    }
    
    private func setOptionalFields(guardianName: String?, guardianEmail: String?) {
        self.guardian_name = guardianName
        self.guardian_email = guardianEmail
    }
    
    
    // Networking //
    
    // TODO: Make these setters call firebase code to set on the backend as well
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
        // TOOD: Generate ID
        let a = Activity(trip_id: tripID, member_id: self.id)
        self.activity_ids.append(a.id)
    }
    
    
    func remove(tripID: String) {
        var activity_id = String()
        Utils.db.collection(Collection.activites.rawValue)
            .whereField(IDField.tripID.rawValue, isEqualTo: tripID)
            .whereField(IDField.memberID.rawValue, isEqualTo: self.id)
            .getDocuments { (snapshot, error) in
                for document in (snapshot?.documents)!{
                    activity_id = document.documentID
                }
        }
        
        let ind = activity_ids.index(of:activity_id)
        self.activity_ids.remove(at: ind!)
        save()
        
        let ref = Utils.db.collection(Collection.trips.rawValue).document(tripID)
        ref.getDocument { (document, error) in
            if var a_ids = document?.data()![IDField.activityIDs.rawValue] as? Array<String> {
                let i = a_ids.index(of: activity_id)
                a_ids.remove(at: i!)
                ref.updateData([IDField.activityIDs.rawValue: a_ids])
            }
        }
        
    }
    
    func save() {
        if (self.id == IDField.none.rawValue) {
            save2()
            return
        }

        let ref = Utils.db.collection(Collection.members.rawValue).document(self.id)
        
        ref.setData([
            Field.type.rawValue: self.type.rawValue,
            Field.fullName.rawValue: self.full_name,
            Field.guardianName.rawValue: self.guardian_name as Any,
            Field.guardianEmail.rawValue: self.guardian_email as Any,
            Field.activityIds.rawValue: self.activity_ids,
            Field.totalDistance.rawValue: self.total_distance,
            Field.totalDuration.rawValue : self.total_duration
        ], options: SetOptions.merge())
    }
    
    // Set Document ID before saving to Firestore
    func save2() {
        let ref = Utils.db.collection(Collection.members.rawValue).document()
        self.id = ref.documentID
        
        ref.setData([
            Field.type.rawValue: self.type.rawValue,
            Field.fullName.rawValue: self.full_name,
            Field.guardianName.rawValue: self.guardian_name as Any,
            Field.guardianEmail.rawValue: self.guardian_email as Any,
            Field.activityIds.rawValue: self.activity_ids,
            Field.totalDistance.rawValue: self.total_distance,
            Field.totalDuration.rawValue: self.total_duration
        ] ,options: SetOptions.merge())
    }
    
    
    // Get Methods //
    
    static func getMembers(callback: @escaping MembersBlock) {
        Utils.db.collection(Collection.members.rawValue).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot, error == nil else {
                debugPrint("Error getting documents: \(String(describing: error))")
                callback(.error, [])
                return
            }
            
            var members = [Member]()
            for document in snapshot.documents {
                let id = document.documentID
                var arr: HardJSON = document.data()
                
                guard
                    let type_raw = arr[Field.type.rawValue] as? String,
                    let type = Member.MemberType(rawValue: type_raw),
                    let full_name = arr[Field.fullName.rawValue] as? String,
                    let activity_ids = arr[Field.activityIds.rawValue] as? [String],
                    let total_distance = arr[Field.totalDistance.rawValue] as? Double,
                    let total_duration = arr[Field.totalDuration.rawValue] as? Double
                else {
                    debugPrint("Failed instantiating member object with data: \(arr)")
                    continue
                }

                let m = Member(id: id, type: type, name: full_name, activity_ids: activity_ids, totalDistance: total_distance, totalDuration: total_duration)
                
                let guardian_name = arr[Field.guardianName.rawValue] as? String
                let guardian_email = arr[Field.guardianEmail.rawValue] as? String
                m.setOptionalFields(guardianName: guardian_name, guardianEmail: guardian_email)
                
                members.append(m)
            }
            
            callback(.success, members)
        }
    }
    
}





