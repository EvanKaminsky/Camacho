//
//  UIExtensions.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/17/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    
    // Note: this does NOT begin the actually refresh action. It does not call self.sendActions(for: UIControlEvents.valueChanged)
    func beginRefreshingManually(animated: Bool) {
        if let scrollView = superview as? UIScrollView {
            UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: .curveEaseInOut, animations: {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - self.frame.height), animated: false)
            }, completion: nil)
        }
        self.beginRefreshing()
    }
    
}
