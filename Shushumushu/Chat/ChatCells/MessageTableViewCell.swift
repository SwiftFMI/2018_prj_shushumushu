//
//  MessageTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 14.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Identifier

extension MessageTableViewCell {
    
    static let sentIdentifier = "SentMessageTableViewCell"
    static let receivedIdentifier = "ReceivedMessageTableViewCell"
}

// MARK: - Properties

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var messageText: UILabel!
    @IBOutlet private weak var roundedView: RoundedView!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var profilePicture: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedView.roundedCorners = 12 * CGFloat(integerLiteral: messageText.calculateMaxLines)
        profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0) / 2
        profilePicture?.layer.masksToBounds = true
    }
}

// MARK: - Population

extension MessageTableViewCell: ChatTableViewCell {
    
    func populateFrom(_ message: Message) {
        messageText.text = message.text
        timestampLabel.text = message.timestamp.timeStampDescription
        self.profilePicture?.image = profilePicture(for: message.sender)
    }
}