//
//  ReceivedMessageTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 14.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class ReceivedMessageTableViewCell: UITableViewCell {
    //Mark - Properties
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedView.roundedCorners = 12 * CGFloat(integerLiteral: messageText.calculateMaxLines())
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}