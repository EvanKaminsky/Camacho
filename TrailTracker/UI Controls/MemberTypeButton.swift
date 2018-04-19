//
//  MemberTypeButton.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/19/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class MemberTypeButton: ClosureButton {
    
    let label = UILabel()
    let icon = UIImageView()
    
    var theme_color: UIColor!
    var is_selected: Bool!
    var text: String!
    
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    init(frame: CGRect, text: String, image: String, isSelected: Bool, themeColor: UIColor) {
        super.init(frame: frame)
        self.text = text
        self.theme_color = themeColor
        self.makeRound(radius: 8)
        let icon_width = 0.2 * self.width
        icon.frame = CGRect(x: 0, y: 0, width: icon_width, height: icon_width)
        icon.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        
        let _ =  isSelected ? self.setIsSelected() : self.setIsNotSelected()
        
        label.textAlignment = .center
        label.frame = self.frame
        label.isUserInteractionEnabled = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        
        icon.center = CGPoint(x: 0.3 * self.width, y: 0.5 * self.height)
        label.center = CGPoint(x: 0.6 * self.width, y: 0.53 * self.height)
        self.addSubview(icon)
        self.addSubview(label)
    }
    
    func toggleSelected() {
        if self.is_selected {
            self.setIsNotSelected()
        } else {
            self.setIsSelected()
        }
    }
    
    private func setIsSelected() {
        self.is_selected = true
        self.backgroundColor = self.theme_color
        self.setText(color: Color.white)
        icon.tintColor = Color.white
        self.deleteBorder()
    }
    
    private func setIsNotSelected() {
        self.is_selected = false
        self.backgroundColor = Color.white
        self.setText(color: self.theme_color)
        icon.tintColor = self.theme_color
        self.makeBorder(width: 1.5, color: self.theme_color)
    }
    
    private func setText(color: UIColor) {
        label.attributedText = Font.make(text: self.text, size: 20, color: color, type: .paneuropa)
    }
    
    
}
