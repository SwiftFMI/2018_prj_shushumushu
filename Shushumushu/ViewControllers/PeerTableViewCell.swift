//
//  PeerTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 11.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class PeerTableViewCell: UITableViewCell {
    //Mark: Properties
    @IBOutlet weak var peerName: UILabel!
    @IBOutlet weak var peerNameInitialLetter: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
}
