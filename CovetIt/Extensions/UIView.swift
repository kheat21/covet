//
//  UIView.swift
//  CovetIt
//
//  Created by Covet on 1/27/22.
//

import Foundation
import UIKit

extension UIView {
    func slideL(duration: TimeInterval = 1.0, onCompleteDelegate: AnyObject? = nil) {
         
        let slideInFromLeftTransition = CATransition()
         if let delegate: AnyObject = onCompleteDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }

        slideInFromLeftTransition.type = CATransitionType.fade
        //slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed

        self.layer.add(slideInFromLeftTransition, forKey: "slideLTransition")
    }
    
}
