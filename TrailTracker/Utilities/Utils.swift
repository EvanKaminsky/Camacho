//
//  Utils.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/1/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import Foundation
import Firebase

typealias HardJSON = [String : Any]
typealias JSON     = [String : Any]?
typealias ObjJSON  = [String : AnyObject]

typealias VoidBlock = () -> ()


class Utils {
    
    static var app_delegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    static var db: Firestore {
        return Utils.app_delegate.db
    }
    
}
