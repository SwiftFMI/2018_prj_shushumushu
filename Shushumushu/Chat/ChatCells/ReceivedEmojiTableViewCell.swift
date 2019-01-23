//
//  ReceivedEmojiTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 23.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class ReceivedEmojiTableViewCell: UITableViewCell {
    //Mark - Properties
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var emojiSymbols: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
        emojiSymbols.font = emojiSymbols.font.withSize(50)
        emojiSymbols.autoresizesSubviews = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
