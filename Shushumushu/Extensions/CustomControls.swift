//
//  UIButton.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 03/02/2019.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Custom Buttons

extension UIButton {
    
    /// Custom configured button for showing unread messages.
    ///
    /// don't forget to set its target
    static var unreadMessagesButton: UIButton {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        result.layer.borderColor = UIColor.black.cgColor
        result.layer.borderWidth = 1.0
        result.titleLabel?.font = .boldSystemFont(ofSize: 32)
        result.setTitle("0", for: .normal)
        result.titleLabel?.textAlignment = .center
        result.layer.cornerRadius = 25
        result.layer.masksToBounds = true
        result.isHidden = true
        return result
    }
}

extension UIButton {
    
    func animateUnreadMessagesView() {
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: { [weak self] in
            self?.transform = .identity
        })
    }
    
    func hideUnreadMessagesView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self?.isHidden = true
        }) { [weak self] _ in
            self?.transform = .identity
        }
    }
    
    func showUnreadMessagesView(for unreadMessagesCount: Int) {
        guard unreadMessagesCount != 0 else { return }
        
        let vibration = UINotificationFeedbackGenerator()
        vibration.notificationOccurred(.success)
        
        isHidden = false
        setTitle("\(unreadMessagesCount)", for: .normal)
        animateUnreadMessagesView()
    }
}
