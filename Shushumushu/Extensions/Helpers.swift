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

extension UInt8 {
    var character: Character {
        return Character(UnicodeScalar(self))
    }
}

// MARK: - Embedding View Controllers

extension UIViewController {
    
    private func removeChildren() {
        children.forEach { $0.removeFromParent() }
    }
    
    /// Embeds easily a view controller inside this one. if called multiple time **pay attention to call** `children.forEach { $0.removeFromParent() }` **when appropriate**
    ///
    /// In case you are not sure when you call this method and whether the view controller is already loaded invoke first `_ = view` to force load the view.
    ///
    /// - Parameters:
    ///   - viewController: the view controller you want to embed.
    ///   - containerView: the view in which you want your view controller visible.
    func embed(_ viewController: UIViewController, in containerView: UIView?) {
        guard let containerView = containerView else { return }
        removeChildren()
        addChild(viewController)
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let top   = NSLayoutConstraint(item: viewController.view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
        let left  = NSLayoutConstraint(item: viewController.view, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: viewController.view, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1, constant: 0)
        let down  = NSLayoutConstraint(item: viewController.view, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
        
        containerView.addConstraints([top, left, right, down])
        viewController.didMove(toParent: self)
    }
}
