//
//  ChatTableViewCell.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 03/02/2019.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - ChatTableViewCell

/// Common requirements for `UITableViewCell`'s from Chat screen.
protocol ChatTableViewCell: class {
    
    /// Common interface for population of chat screen's cells.
    func populateFrom(_ message: Message)
}

// MARK: Helper Methods

extension ChatTableViewCell {
    
    func profilePicture(for sender: MCPeerID) -> UIImage? {
        let picture = PeerService.shared.foundPeers.first(where: { $0.id == sender })?.profilePicture
        return picture
    }
}
