//
//  ShareSheetUIConfig.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation
import UIKit

extension ShareSheetViewController {
    func navbarHeight() -> Double {
        return 44.0
    }
    
    func fromTop(y: Double) -> Double {
        return y + navbarHeight()
    }
    
    func centerX(width: Double) -> Double {
        return middleX() - (width / 2)
    }
    
    func centerY(height: Double) -> Double {
        return middleY() - (height / 2)
    }
    
    func middleX() -> Double {
        return self.view.frame.width / 2.0
    }
    
    func middleY() -> Double {
        return self.view.frame.height / 2.0
    }
    
    func paddedXLeft() -> Double {
        return 16
    }
    
    func paddedWidth() -> Double {
        return self.view.frame.width - (paddedXLeft() * 2)
    }
}
