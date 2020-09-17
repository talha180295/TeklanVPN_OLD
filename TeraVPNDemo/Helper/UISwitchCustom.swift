//
//  UISwitchCustom.swift
//  Bidkum
//
//  Created by dev on 18/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

class UISwitchCustom: UISwitch {
    
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint

//            self.tintColor = OffTint
//            self.layer.cornerRadius = self.frame.height / 2
//            self.backgroundColor = OffTint
//            self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }
    }
    @IBInspectable var Scale: CGFloat = 0.0 {
        didSet {
        
            self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }
    }
    

}
