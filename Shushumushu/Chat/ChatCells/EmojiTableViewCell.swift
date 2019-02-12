//
//  EmojiTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 23.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Identifiers

extension EmojiTableViewCell {
    
    static let sentIdentifier = "SentEmojiTableViewCell"
    static let receivedIdentifier = "ReceivedEmojiTableViewCell"
}

// MARK: - Properties

class EmojiTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var profilePicture: UIImageView?
    @IBOutlet private weak var emojiSymbols: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    var isSeen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0) / 2
        profilePicture?.layer.masksToBounds = true
        emojiSymbols.font = emojiSymbols.font.withSize(50)
        emojiSymbols.autoresizesSubviews = true
    }
}

// MARK: - ChatTableViewCell protocol

extension EmojiTableViewCell: ChatTableViewCell {
    
    func addSeenToTimestampLabel() {
        if profilePicture != nil && isSeen == false {
            timestampLabel.text = "\(timestampLabel.text ?? "") Seen"
            isSeen = true
        } else if isSeen == false {
            timestampLabel.text = "Seen \(timestampLabel.text ?? "")"
            isSeen = true
        }
    }
    
    func populateFrom(_ message: Message) {
        emojiSymbols.text = message.text
        timestampLabel.text = message.timestamp.timeStampDescription
        self.profilePicture?.image = profilePicture(for: message.sender)      
    }
}
