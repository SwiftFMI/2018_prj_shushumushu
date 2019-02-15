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
    @IBOutlet weak var seenLabel: UILabel!
    
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
    
    func setSeen(to isSeen: Bool) {
        self.isSeen = isSeen
        updateSeenLabelVisibility()
    }
    
    func updateSeenLabelVisibility() {
        if profilePicture == nil {
            seenLabel.isHidden = !isSeen
        }
    }
    
    func populateFrom(_ message: Message) {
        emojiSymbols.text = message.text
        timestampLabel.text = message.timestamp.timeStampDescription
        self.profilePicture?.image = profilePicture(for: message.sender)      
    }
}
