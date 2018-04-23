//
//  Badge.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/19/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class Badge: UIView {
    
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    init(frame: CGRect, text: String, backgroundColor: UIColor) {
        super.init(frame: frame)
        self.initialize()
    }
    
    func initialize() {
        self.makeRound(radius: 5)
        
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 0.9 * self.width, height: 0.95 * self.height)
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        self.addSubviewInCenter(label)
        
    }
    
    func set(text: String, backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        label.attributedText = Font.make(text: text, size: 17, color: Color.white, type: .paneuropa)
    }
    
    
    
    
    
}
