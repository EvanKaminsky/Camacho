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
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    init(frame: CGRect, text: String, backgroundColor: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        
        self.makeRound(radius: 5)

        label.attributedText = Font.make(text: text, size: 17, color: Color.white, type: .paneuropa)
        label.textAlignment = .center
        label.frame = self.frame
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        self.addSubview(label)
    }
    
}
