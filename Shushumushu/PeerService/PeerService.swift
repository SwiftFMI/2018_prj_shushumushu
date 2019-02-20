//
//  PeerService.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 12.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Peer {
    
    var id: MCPeerID
    var profilePicture: UIImage
}

extension Peer {
    
    func compareId(with peer: Peer) -> Bool {
        return id == peer.id
    }
}

protocol PeerServiceDelegate: class {
    
    func foundPeer()
    func lostPeer(at index: Int)
}

class PeerService: NSObject {
    
    static var shared = PeerService()
    
    private let PeerServiceType = "ssms-mpc"
    
    var session : MCSession!
    let myPeerId = MCPeerID.reusableInstance(withDisplayName: UserDefaults.standard.string(forKey: "username")!);
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    var foundPeers: [Peer] = []
    var messages = [Message]()
    var selectedEmoji = "👍"
    
    weak var delegate: PeerServiceDelegate?
    
    override init() {
        super.init()
        
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: PeerServiceType)
        serviceAdvertiser.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeerServiceType)
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    func handlePeerInvitation(peer: Peer) -> Void {
        for (index, foundPeer) in foundPeers.enumerated() {
            if (peer.id == foundPeer.id) {
                if (peer.profilePicture != foundPeer.profilePicture) {
                    foundPeers[index].profilePicture = peer.profilePicture
                }
                return
            }
        }
        
        foundPeers.append(peer)
        delegate?.foundPeer()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
}

// MARK: - Messages Count

extension PeerService {
    
    func totalNumberOfMessages(with peer: MCPeerID) -> Int {
        var numberOfMessages = 0
        
        for message in messages {
            if (message.sender == peer && message.receiver == myPeerId) || (message.sender == myPeerId && message.receiver == peer) {
                numberOfMessages += 1
            }
        }
        
        return numberOfMessages
    }
    
    func indexOfLastMessageSentByMe(with peer: MCPeerID) -> Int {
        let numberOfMessages = totalNumberOfMessages(with: peer)
        
        for index in stride(from: numberOfMessages - 1, through: 0, by: -1) {
            if messages[index].sender == myPeerId && messages[index].receiver == peer {
                return index
            }
        }
        
        return numberOfMessages
    }
}

// MARK: - Advertiser Delegate

extension PeerService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from peer \(peerID)")
        if let contextData = context {
            if let profilePicture = UIImage(data: contextData) {
                print("Received profile picture from peer \(peerID)")
                self.handlePeerInvitation(peer: Peer(id: peerID, profilePicture: profilePicture))
                invitationHandler(true, self.session)
                return
            }
        }
        
        invitationHandler(false, self.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
}

// MARK: - Browser Delegate

extension PeerService: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer with id: \(peerID)")
        //        let profilePic = UIImage(named: "default-profile-pic")
        guard let profilePictureData = UserDefaults.standard.data(forKey: "profilePic") else { return }
        browser.invitePeer(peerID, to: session, withContext: profilePictureData, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer with id: \(peerID)")
        
        var atIndex: Int?
        
        for (index, peer) in foundPeers.enumerated() {
            if (peer.id == peerID) {
                foundPeers.remove(at: index)
                atIndex = index
                delegate?.lostPeer(at: atIndex!)
                break
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - Session Delegate

extension PeerService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data: \(data) from: \(peerID)")
        if let receivedImage = UIImage(data: data) {
            let newMessage = Message(sender: peerID, receiver: myPeerId, image: receivedImage)
            messages.append(newMessage)
            NotificationCenter.default.post(name: .messageReceived, object: nil, userInfo: ["message" : newMessage])
        } else if let receivedText = String(data: data, encoding: .utf8) {
            
            if receivedText.isCustomNotification {
                handleCustomNotification(receivedText, fromPeer: peerID)
                return
            }
            
            let newMessage = Message(sender: peerID, receiver: myPeerId, text: receivedText)
            messages.append(newMessage)
            NotificationCenter.default.post(name: .messageReceived, object: nil, userInfo: ["message" : newMessage])
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received \(streamName) from: \(peerID)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving a resource from: \(peerID)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Finished receiving a resource from: \(peerID)")
    }
}

// MARK: - Custom Notification Handling

extension PeerService {
    
    func handleCustomNotification(_ customNotification: String, fromPeer peerID: MCPeerID) {
        if customNotification == String.messageDelivered {
            NotificationCenter.default.post(name: Notification.Name.messageDelivered, object: nil, userInfo: ["sender" : peerID])
            print("Delivered notification received")
        } else if customNotification == String.messageSeen {
            NotificationCenter.default.post(name: Notification.Name.messageSeen, object: nil, userInfo: ["sender" : peerID])
            print("Seen notification received")
        }
    }
    
    func sendNotification(_ notification: String, to peerID: MCPeerID) {
        do {
            if let messageData = notification.data(using: .utf8) {
                try PeerService.shared.session.send(messageData, toPeers: [peerID], with: .reliable)
            }
        } catch { return }
    }
}

// MARK: - Logging Out

extension PeerService {
    
    static func logOut() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        PeerService.shared.serviceAdvertiser.stopAdvertisingPeer()
        PeerService.shared.serviceBrowser.stopBrowsingForPeers()
    }
}
