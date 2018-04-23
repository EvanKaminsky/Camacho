//
//  Font.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/12/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

typealias FontAttributes = [NSAttributedStringKey : Any]

class Font {
    
    enum Name: String {
        case sunn       = "SUNN"
        case paneuropa  = "PaneuropaNeueRegular"
    }

    static func makeAttrs(size: CGFloat, color: UIColor, type: Font.Name) -> FontAttributes {
        if let font = UIFont(name: type.rawValue, size: size) {
            return [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color]
        }
        
        debugPrint("Could not create font of size: \(size), color: \(color), type: \(type)")
        return [NSAttributedStringKey.foregroundColor: color]
    }
    
    
    static func make(text: String, size: CGFloat, color: UIColor, type: Font.Name) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: Font.makeAttrs(size: size, color: color, type: type))
    }
    
    
    static func make(text: String, attributes: FontAttributes) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes)
    }
    

}
