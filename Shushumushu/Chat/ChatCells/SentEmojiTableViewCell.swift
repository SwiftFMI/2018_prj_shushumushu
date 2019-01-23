//
//  SentEmojiTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 23.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class SentEmojiTableViewCell: UITableViewCell {
    @IBOutlet weak var emojiSymbols: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emojiSymbols.font = emojiSymbols.font.withSize(50)
        emojiSymbols.autoresizesSubviews = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
