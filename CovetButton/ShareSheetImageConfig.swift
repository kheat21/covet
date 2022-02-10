//
//  ShareSheetImageConfig.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation
import UIKit

extension ShareSheetViewController {

    func getImageSize() -> Double {
        let minimum = 128.0
        
        var scaled = self.view.frame.width - (64 * 2)
        while scaled > self.view.frame.height * 0.4 {
            scaled -= 10.0
        }
        
        if scaled < minimum {
            return minimum
        } else {
            return scaled
        }
    }

}
