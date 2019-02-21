//
//  ColorPickerViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 21.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    @IBOutlet var colorRoundedViews: [RoundedView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged), name: .colorChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .colorChanged, object: nil)
    }
}


// MARK: - Color Changes Notifications

extension Notification.Name {
    
    static let colorChanged = Notification.Name("color-changed")
}

extension ColorPickerViewController {
    
    @objc func colorChanged(_ sender: Any) {
        for view in colorRoundedViews {
            for subview in view.subviews {
                subview.isHidden = true
            }
        }
    }
}

// MARK: - User Interactions

extension ColorPickerViewController {
    
    @IBAction func didTapColorView(_ sender: UITapGestureRecognizer) {
        PeerService.shared.selectedChatColor = sender.view?.backgroundColor ?? PeerService.shared.selectedChatColor
        NotificationCenter.default.post(Notification(name: .colorChanged, object: nil))
        sender.view?.subviews[0].isHidden = false
    }
}
