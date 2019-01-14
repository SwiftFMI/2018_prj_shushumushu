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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
