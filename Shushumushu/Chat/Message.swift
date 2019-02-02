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
    let text: String?
    let image: UIImage?
    let timestamp: TimeInterval
    let messageType: MessageType
    
    enum MessageType {
        case Image
        case Text
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, text: String?) {
        self.sender = sender
        self.receiver = receiver
        self.text = text
        self.image = nil
        self.messageType = .Text
        timestamp = Date().timeIntervalSince1970
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, image: UIImage?) {
        self.sender = sender
        self.receiver = receiver
        self.image = image
        self.text = nil
        self.messageType = .Image
        timestamp = Date().timeIntervalSince1970
    }
}
