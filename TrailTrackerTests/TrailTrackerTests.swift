//
//  TrailTrackerTests.swift
//  TrailTrackerTests
//
//  Created by Matthew on 4/12/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import XCTest
import Firebase
@testable import TrailTracker

class TrailTrackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let trip = Trip(id: "tripA", type: .biking, status: .complete, title: "Trip 1", activity_ids: ["activity1", "activity2"], staffCount: 3, participantCount: 12)
        trip.set(distance: 4.8)
        trip.set(startTime: Date())
        trip.set(endTime: Date())
        print("Going to save")
        trip.save()
        print("Just Saved")
        let t_ref = Utils.db.collection("Trips").document("tripA")
        t_ref.getDocument{ (document,error) in
            if let document = document, document.exists{
                let contents = document.data().map(String.init(describing:)) ?? "nil"
                print(contents)
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
