//
//  ChatColorPickerTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 21.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class ExampleChatTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var messageViews: [RoundedView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
        imageView.layer.borderWidth = 3
        
        for message in messageViews {
            message.backgroundColor = PeerService.shared.selectedChatColor
        }
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged), name: .colorChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .colorChanged, object: nil)
    }
}

// MARK: - Notificaitons

extension ExampleChatTableViewController {
    
    @objc func colorChanged(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            for message in (self?.messageViews)! {
                message.backgroundColor = PeerService.shared.selectedChatColor
            }
        })
    }
}
