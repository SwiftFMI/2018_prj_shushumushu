//
//  Helpers.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 03/02/2019.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

extension Date {
    
    var timeStampDescription: String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm"
        let dateString = dayTimePeriodFormatter.string(from: self)
        return dateString
    }
}

extension UILabel {

    var calculateMaxLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
}

extension CGAffineTransform {
    
    var scaleX: CGFloat {
        return (a > 0 ? 1 : -1) * sqrt (a*a + c*c)
    }
    
    var scaleY: CGFloat {
        return (d > 0 ? 1 : -1) * sqrt (b*b + d*d)
    }
}
