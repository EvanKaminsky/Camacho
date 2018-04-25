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
        case tripIds = "trip_ids"
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
    
    private(set) var trip_ids: Array<String>
    private(set) var total_distance: CGFloat
    private(set) var total_duration: CGFloat
    
    var total_trips: Int {
        return trip_ids.count
    }
    
    init(id: String, type: MemberType, name: String, trip_ids: [String], totalDistance: CGFloat, totalDuration: CGFloat) {
        self.id = id
        self.type = type
        self.full_name = name
        self.trip_ids = trip_ids
        self.total_distance = totalDistance
        self.total_duration = totalDuration
    }
    
    private func setOptionalFields(guardianName: String?, guardianEmail: String?) {
        self.guardian_name = guardianName
        self.guardian_email = guardianEmail
    }
    
    
    // Networking //
    
    static func create(type: MemberType, name: String, guardianName: String?, guardianEmail: String?) {
        let member = Member(id: IDField.none.rawValue, type: type, name: name, trip_ids: [], totalDistance: 0, totalDuration: 0)
        member.setOptionalFields(guardianName: guardianName, guardianEmail: guardianEmail)
        member.save()
    }
    
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
        self.trip_ids.append(trip_id)
        save()
        // Query for the trip and add member to it
        var member_ids = [String]()
        Utils.db.collection(Collection.trips.rawValue).document(trip_id)
            .addSnapshotListener{(documentSnapshot,error) in
                guard let document = documentSnapshot, error == nil else{
                    debugPrint("Error getting document: \(String(describing: error))")
                    callback(.error)
                    return
                }
                let arr: HardJSON = document.data()!
                member_ids = (arr[Trip.Field.memberIds.rawValue] as? [String])!
                member_ids.append(trip_id)
                
                let ref = Utils.db.collection(Collection.trips.rawValue).document(trip_id)
                ref.setData([
                    Trip.Field.memberIds.rawValue: member_ids
                    ], options: SetOptions.merge())
                callback(.success)
        }
    }
    
    
    func removeTrip(trip_id: String) {
        if let index = trip_ids.index(of: trip_id) {
            self.trip_ids.remove(at: index)
        }
        save()
        
        let ref = Utils.db.collection(Collection.trips.rawValue).document(trip_id)
        ref.getDocument { (document, error) in
            if let data = document?.data(), var member_ids = data[Trip.Field.memberIds.rawValue] as? [String] {
                if let index = member_ids.index(of: self.id) {
                    member_ids.remove(at: index)
                    ref.updateData([Trip.Field.memberIds.rawValue: member_ids])
                }
            }
        }
        
    }
    
    // Remove Member from database
    func remove(){
        
        var ref: DocumentReference!
        for tid in self.trip_ids{
            ref = Utils.db.collection(Collection.trips.rawValue).document(tid)
            ref.getDocument{(document, err) in
                let arr: HardJSON = document!.data()!
                var member_ids = arr[Trip.Field.memberIds.rawValue] as! [String]
                if let index = member_ids.index(of: self.id) {
                    member_ids.remove(at: index)
                    ref.updateData([Trip.Field.memberIds.rawValue: member_ids])
                }
            }
        }
 
        Utils.db.collection(Collection.members.rawValue).document(self.id).delete(){ err in
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
            Field.tripIds.rawValue: self.trip_ids,
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
                let trip_ids = arr[Field.tripIds.rawValue] as? [String],
                let total_distance = arr[Field.totalDistance.rawValue] as? CGFloat,
                let total_duration = arr[Field.totalDuration.rawValue] as? CGFloat
                else {
                    debugPrint("Failed instantiating member object with data: \(arr)")
                    callback(.error,nil)
                    return
                }
            let m = Member(id: id, type: type, name: full_name, trip_ids: trip_ids, totalDistance: total_distance, totalDuration: total_duration)
            
            let guardian_name = arr[Field.guardianName.rawValue] as? String
            let guardian_email = arr[Field.guardianEmail.rawValue] as? String
            m.setOptionalFields(guardianName: guardian_name, guardianEmail: guardian_email)
            callback(.success, m)
        }
    }
    
    
    func getTrips(callback: @escaping TripsBlock) {
        var trips = [Trip]()
        
        for tid in self.trip_ids {
            Trip.getTrip(trip_id: tid) { (status, trip) in
                if status == .success, let trip = trip {
                    trips.append(trip)
                } else {
                    debugPrint("Trip \(tid) does not exist, Status: \(status)")
                    callback(.error,[])
                }
            }
        }
        callback(.success,trips)
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
                    let trip_ids = arr[Field.tripIds.rawValue] as? [String],
                    let total_distance = arr[Field.totalDistance.rawValue] as? CGFloat,
                    let total_duration = arr[Field.totalDuration.rawValue] as? CGFloat
                else {
                    debugPrint("Failed instantiating member object with data: \(arr)")
                    continue
                }

                let m = Member(id: id, type: type, name: full_name, trip_ids: trip_ids, totalDistance: total_distance, totalDuration: total_duration)
                
                let guardian_name = arr[Field.guardianName.rawValue] as? String
                let guardian_email = arr[Field.guardianEmail.rawValue] as? String
                m.setOptionalFields(guardianName: guardian_name, guardianEmail: guardian_email)
                
                members.append(m)
            }
            
            callback(.success, members)
        }
    }
    
}





