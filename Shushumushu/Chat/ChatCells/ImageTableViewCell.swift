//
//  ImageTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 1.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Identifiers

extension ImageTableViewCell {
    
    static let sentIdentifier = "SentImageTableViewCell"
    static let receivedIdentifier = "ReceivedImageTableViewCell"
}

// MARK: - Properties

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet private weak var profilePicture: UIImageView?
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    var isSeen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentImageView.layer.cornerRadius = 25
        contentImageView.clipsToBounds = true
        contentImageView.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
        contentImageView.layer.borderWidth = 3
        
        profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0) / 2
        profilePicture?.layer.masksToBounds = true
    }
}

// MARK: - ChatTableViewCell protocol

extension ImageTableViewCell: ChatTableViewCell {
    
    func setSeen(to isSeen: Bool) {
        self.isSeen = isSeen
    }
    
    func updateSeenLabelVisibility() {
        if profilePicture == nil {
            seenLabel.isHidden = !isSeen
        }
    }
    
    func populateFrom(_ message: Message) {
        contentImageView.image = message.image
        timestampLabel.text = message.timestamp.timeStampDescription
        self.profilePicture?.image = profilePicture(for: message.sender)
    }
}
