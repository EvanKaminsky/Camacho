//
//  UIView+.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/12/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

extension UIView {
    
    var height: CGFloat {
        return self.bounds.height
    }
    
    var width: CGFloat {
        return self.bounds.width
    }
    
    var mid: CGPoint {
        return CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    func resize(newWidth: CGFloat) {
        let old_center = self.center
        self.sizeToFit()
        self.frame = CGRect(x: 0, y: 0, width: newWidth, height: newWidth * self.height / self.width)
        self.center = old_center
    }
    
    func resize(newHeight: CGFloat) {
        let old_center = self.center
        self.sizeToFit()
        self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: newHeight)
        self.center = old_center
    }
    
    func bubble() {
        bubble(duration: nil, x: nil, y: nil, damping: nil, velocity: nil, options: nil)
    }
    
    func bubble(duration: TimeInterval? = nil, x: CGFloat? = nil, y: CGFloat? = nil, damping: CGFloat? = nil, velocity: CGFloat? = nil, options: UIViewAnimationOptions? = nil) {
        self.transform = CGAffineTransform(scaleX: x ?? 0.75, y: y ?? 0.75)
        
        UIView.animate(withDuration: duration ?? 1.0, delay: 0, usingSpringWithDamping: damping ?? 0.25, initialSpringVelocity: CGFloat(velocity ?? 3), options: options ?? [], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
    
    func makeRound(radius: CGFloat = 3) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func makeBorder(width: CGFloat = 0.1, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func deleteBorder() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func makeShadow(opacity: Float = 0.2, radius: CGFloat = 4.0, offsetWidth: CGFloat = 0, offsetHeight: CGFloat = 0) {
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOffset  = CGSize(width: offsetWidth, height: offsetHeight)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius  = radius
        self.clipsToBounds = false
    }
    
    func makeShadowAndCircular() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.makeShadow(opacity: 0.1, radius: 4.0)
    }

    func addSubviewInCenter(_ view: UIView) {
        view.center = self.mid
        self.addSubview(view)
    }
    
    func setRecursiveUserInteraction(enabled: Bool) {
        self.isUserInteractionEnabled = enabled
        for view in self.subviews {
            view.setRecursiveUserInteraction(enabled: enabled)
        }
    }
    
}







