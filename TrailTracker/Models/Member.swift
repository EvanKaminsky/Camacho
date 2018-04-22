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
    private(set) var total_distance: CGFloat
    private(set) var total_duration: CGFloat
    
    var total_trips: Int {
        return activity_ids.count
    }
    
    init(id: String, type: MemberType, name: String, activity_ids: [String], totalDistance: CGFloat, totalDuration: CGFloat) {
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
    
    func set(name: String) {
        self.full_name = name
        save()
    }
    
    func set(guardianName: String) {
        self.guardian_name = guardianName
        save()
    }
    
    func set(guardianEmail: String) {
        self.guardian_email = guardianEmail
        save()
    }
    
    func add(trip_id: String, callback: @escaping StatusBlock) {
        let a = Activity(trip_id: trip_id, member_id: self.id)
        self.activity_ids.append(a.id)
        save()
        // Add activity id to the Trip
        var activity_ids = [String]()
        Utils.db.collection(Collection.trips.rawValue).document(trip_id)
            .addSnapshotListener{(documentSnapshot,error) in
                guard let document = documentSnapshot, error == nil else{
                    debugPrint("Error getting document: \(String(describing: error))")
                    callback(.error)
                    return
                }
                let arr: HardJSON = document.data()!
                activity_ids = (arr[Field.activityIds.rawValue] as? [String])!
                activity_ids.append(a.id)
        }
        let ref = Utils.db.collection(Collection.trips.rawValue).document(trip_id)
        ref.setData([
            Field.activityIds.rawValue: activity_ids
            ], options: SetOptions.merge())
        callback(.success)
    }
    
    
    func remove(tripID: String) {
        var activity_id = String()
        Utils.db.collection(Collection.activites.rawValue)
            .whereField(IDField.tripID.rawValue, isEqualTo: tripID)
            .whereField(IDField.memberID.rawValue, isEqualTo: self.id)
            .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        activity_id = document.documentID
                    }
                }
        }
        
        if let index = activity_ids.index(of: activity_id) {
            self.activity_ids.remove(at: index)
        }
        save()
        let ref = Utils.db.collection(Collection.trips.rawValue).document(tripID)
        ref.getDocument { (document, error) in
            if let data = document?.data(), var activity_ids = data[IDField.activityIDs.rawValue] as? [String] {
                if let index = activity_ids.index(of: activity_id) {
                    activity_ids.remove(at: index)
                    ref.updateData([IDField.activityIDs.rawValue: activity_ids])
                }
            }
        }
        // Remove orphaned activity
        Utils.db.collection(Collection.activites.rawValue).document(activity_id).delete(){ err in
            if let err = err {
                debugPrint("Error removing document: \(err)")
            } else {
                debugPrint("Document successfully removed!")
            }
        }
        
    }
    
    private func save() {
        var ref: DocumentReference!
        if (self.id == IDField.none.rawValue) {
            // Set Document ID before saving to Firestore
            ref = Utils.db.collection(Collection.members.rawValue).document()
            self.id = ref.documentID
        } else {
            ref = Utils.db.collection(Collection.members.rawValue).document(self.id)
        }
        
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
    
    
    // Get Methods //
    
    static func getMember(member_id: String, callback: @escaping MemberBlock){
        Utils.db.collection(Collection.members.rawValue).document(member_id)
        .addSnapshotListener{ (documentSnapshot, error) in
            guard let document = documentSnapshot, error == nil else {
                debugPrint("Error getting document: \(String(describing: error))")
                callback(.error,nil)
                return
            }
            let id = document.documentID
            var arr: HardJSON = document.data()!    
            guard
                let type_raw = arr[Field.type.rawValue] as? String,
                let type = Member.MemberType(rawValue: type_raw),
                let full_name = arr[Field.fullName.rawValue] as? String,
                let activity_ids = arr[Field.activityIds.rawValue] as? [String],
                let total_distance = arr[Field.totalDistance.rawValue] as? CGFloat,
                let total_duration = arr[Field.totalDuration.rawValue] as? CGFloat
                else {
                    debugPrint("Failed instantiating member object with data: \(arr)")
                    callback(.error,nil)
                    return
                }
            let m = Member(id: id, type: type, name: full_name, activity_ids: activity_ids, totalDistance: total_distance, totalDuration: total_duration)
            
            let guardian_name = arr[Field.guardianName.rawValue] as? String
            let guardian_email = arr[Field.guardianEmail.rawValue] as? String
            m.setOptionalFields(guardianName: guardian_name, guardianEmail: guardian_email)
            callback(.success, m)
        }
    }
    
    
    func getTrips() -> [Trip]{
        var trips = [Trip]()
        for aid in self.activity_ids{
            Utils.db.collection(Collection.activites.rawValue).document(aid).getDocument{(document,err) in
                if let err = err{
                    debugPrint("Error getting document: \(err)")
                }else{
                    var arr : HardJSON = document!.data()!
                    let trip_id  = arr[IDField.tripID.rawValue] as? String
                    Trip.getTrip(trip_id: trip_id!) { (status,trip) in
                        if status == .error{
                            debugPrint("Trip does not Exist: \(status)")
                        }else{
                            trips.append(trip!)
                        }
                    }
                }
            }
        }
        return trips
    }
    
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
                    let total_distance = arr[Field.totalDistance.rawValue] as? CGFloat,
                    let total_duration = arr[Field.totalDuration.rawValue] as? CGFloat
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





