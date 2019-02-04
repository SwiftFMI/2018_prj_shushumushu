//
//  Message.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 7.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Universal Instance

extension Message {
    
    static func createFrom(sender: MCPeerID, receiver: MCPeerID, data: Data) -> Message? {
            
        if let image = UIImage(data: data) {
            return Message(sender: sender, receiver: receiver, image: image)
        }
        else if let text = String(bytes: data, encoding: .utf8) {
            return Message(sender: sender, receiver: receiver, text: text)
        }
        return nil
    }
}

// MARK: - Class Definition

class Message {
    let sender: MCPeerID
    let receiver: MCPeerID
    let text: String?
    let image: UIImage?
    let timestamp: Date //TimeInterval
    let messageType: MessageType
    
    enum MessageType {
        case image
        case text
        case emojiOnly
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, text: String?) {
        self.sender = sender
        self.receiver = receiver
        self.text = text
        self.image = nil
        messageType = text?.containsOnlyEmoji == true ? .emojiOnly : .text
        timestamp = Date()
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, image: UIImage?) {
        self.sender = sender
        self.receiver = receiver
        self.image = image
        self.text = nil
        messageType = .image
        timestamp = Date()
    }
}

// MARK: - Convenience Methods

extension Message {
    
    /// Gives info whether the current message is send by the local user on this device.
    var isSendByLocalUser: Bool { return sender == PeerService.shared.myPeerId }
}
