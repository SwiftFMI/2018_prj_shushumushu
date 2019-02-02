//
//  SentImageTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 1.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class SentImageTableViewCell: UITableViewCell {
    @IBOutlet weak var sentImage: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sentImage.layer.cornerRadius = 25
        sentImage.clipsToBounds = true
        sentImage.layer.borderColor = UIColor(red: 0, green: 0.51, blue: 1, alpha: 1).cgColor
        sentImage.layer.borderWidth = 3
    }
}
