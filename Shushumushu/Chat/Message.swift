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
    var messageStatus: MessageStatus
    
    enum MessageType {
        case image
        case text
        case emojiOnly
    }
    
    enum MessageStatus {
        case sent
        case delivered
        case seen
        case notSet
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, text: String?) {
        self.sender = sender
        self.receiver = receiver
        self.text = text
        self.image = nil
        messageType = text?.containsOnlyEmoji == true ? .emojiOnly : .text
        messageStatus = .notSet
        timestamp = Date()
        addNotificationObservers()
    }
    
    init(sender: MCPeerID, receiver: MCPeerID, image: UIImage?) {
        self.sender = sender
        self.receiver = receiver
        self.image = image
        self.text = nil
        messageType = .image
        messageStatus = .notSet
        timestamp = Date()
        addNotificationObservers()
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(deliveredAction), name: .messageDelivered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(seenAction), name: .messageSeen, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .messageDelivered, object: nil)
        NotificationCenter.default.removeObserver(self, name: .messageSeen, object: nil)
    }
}

// MARK: - Convenience Methods

extension Message {
    
    /// Gives info whether the current message is send by the local user on this device.
    var isSendByLocalUser: Bool { return sender == PeerService.shared.myPeerId }
}

// MARK: - Notification Handlers

extension Message {
    
    @objc func deliveredAction() {
        
        messageStatus = .delivered
        //NotificationCenter.default.post(name: .messageDidChangeStatus, object: self)
    }
    
    @objc func seenAction() {
        
        messageStatus = .seen
        //NotificationCenter.default.post(name: .messageDidChangeStatus, object: self)
    }
}

// MARK: - Message Status Notifications

extension Notification.Name {
    
    static let messageDelivered = Notification.Name("message-delivered")
    static let messageSeen = Notification.Name("message-seen")
    static let messageReceived = Notification.Name("message-received")
    static let messageDidChangeStatus = Notification.Name("message-did-change-status")
}
