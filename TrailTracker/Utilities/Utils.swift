//
//  Utils.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import Firebase


// Global Fields //

let DEBUG_ON = true

var SHOULD_RELOAD_MEMBERS = false
var SHOULD_RELOAD_TRIPS = false

typealias HardJSON = [String : Any]
typealias JSON     = [String : Any]?
typealias ObjJSON  = [String : AnyObject]
typealias VoidBlock = () -> ()
typealias StatusBlock = (NetworkingStatus) -> ()
typealias MembersBlock = (NetworkingStatus, [Member]) -> ()
typealias MemberBlock = (NetworkingStatus, Member?) -> ()
typealias TripsBlock = (NetworkingStatus, [Trip]) -> ()
typealias TripBlock = (NetworkingStatus, Trip?) -> ()


// Global Functions //

func debugPrint(_ text: String) {
    if DEBUG_ON {
        print("[\(Date())] > \(text)")
    }
}

func async(after seconds: Double, function: @escaping VoidBlock) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
        function()
    }
}


// Foundation Extensions //

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CGFloat {
    func roundDigits(from minSig: Int, to maxSig: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 0
        formatter.minimumSignificantDigits = minSig
        formatter.maximumSignificantDigits = maxSig
        
        if let string = formatter.string(from: NSNumber(floatLiteral: Double(self))) {
            return string
        }
        return ""
    }
}

extension Int {
    func roundDigits(from minSig: Int, to maxSig: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumSignificantDigits = minSig
        formatter.maximumSignificantDigits = maxSig
        
        if let string = formatter.string(from: NSNumber(integerLiteral: self)) {
            return string
        }
        return ""
    }
}



// Utility Singleton Class //

class Utils {
    
    static var app_delegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    static var db: Firestore {
        return Utils.app_delegate.db
    }
    
    static var screen: CGSize {
        return UIScreen.main.bounds.size
    }
    
}
