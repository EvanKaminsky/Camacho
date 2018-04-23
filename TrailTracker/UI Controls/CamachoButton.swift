//
//  CamachoButton.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/12/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class CamachoButton: ClosureButton {
    
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    init(frame: CGRect, text: String, backgroundColor: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        
        self.makeShadowAndCircular()
        self.makeBorder(width: 2, color: Color.white)
        
        label.attributedText = Font.make(text: text, size: 35, color: Color.white, type: .sunn)
        label.textAlignment = .center
        label.frame = self.frame
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        self.addSubviewInCenter(label)
    }
    
    func addToView() {
        guard let window = UIApplication.shared.keyWindow else {
            debugPrint("Error: Couldn't access application's key window")
            return
        }
        self.center = CGPoint(x: window.frame.midX, y: 0.92 * Utils.screen.height)
        window.addSubview(self)
    }
    
    
    
    
}
