//
//  RoundedButton.swift
//  Bidkum
//
//  Created by dev on 19/02/2020.
//  Copyright © 2020 bidkum. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton:UIButton {
  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable lazy var isRoundRectButton : Bool = false

    @IBInspectable public var cornerRadius : CGFloat = 0.0 {
        didSet{
            setUpView()
        }
    }

    @IBInspectable public var borderColor : UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    //  MARK:   Awake From Nib

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }

    func setUpView() {
        if isRoundRectButton {
            self.layer.cornerRadius = self.bounds.height/2;
            self.clipsToBounds = true
        }
        else{
            self.layer.cornerRadius = self.cornerRadius;
            self.clipsToBounds = true
        }
    }

}
