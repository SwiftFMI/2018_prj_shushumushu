//
//  RoundedButton.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 4.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    @IBInspectable var roundedCorners: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = roundedCorners
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
