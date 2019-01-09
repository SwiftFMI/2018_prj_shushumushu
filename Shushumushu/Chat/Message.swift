//
//  Message.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 7.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Message: NSObject {
    let sender: MCPeerID
    let receiver: MCPeerID
    let timestamp: TimeInterval
    
    init(sender: MCPeerID, receiver: MCPeerID) {
        self.sender = sender
        self.receiver = receiver
        timestamp = Date().timeIntervalSince1970
    }
}
