//
//  RoundedView.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 11.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    @IBInspectable var roundedCorners: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = roundedCorners;
        }
    }
}
