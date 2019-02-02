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

protocol PeerServiceDelegate: class {
    func foundPeer()
    func lostPeer(at index: Int)
}

class PeerService: NSObject {
    
    static var peerService = PeerService()
    
    private let PeerServiceType = "ssms-mpc"
    
    var session : MCSession!
    let myPeerId = MCPeerID.reusableInstance(withDisplayName: UserDefaults.standard.string(forKey: "username")!);
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    var foundPeers: [Peer] = []
    var messages = [Message]()
    
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
        
        self.foundPeers.append(peer)
        delegate?.foundPeer()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
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
        let profilePictureData = UserDefaults.standard.data(forKey: "profilePic")!
        
        browser.invitePeer(peerID, to: self.session, withContext: profilePictureData, timeout: 10)
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
        if let receivedImage = UIImage(data: data){
            let newMessage = Message(sender: peerID, receiver: myPeerId, image: receivedImage)
            messages.append(newMessage)
            NotificationCenter.default.post(name: Notification.Name.messageReceived, object: nil, userInfo: ["message" : newMessage])
        } else {
            let receivedText = String(decoding: data, as: UTF8.self) 
            let newMessage = Message(sender: peerID, receiver: myPeerId, text: receivedText)
            messages.append(newMessage)
            NotificationCenter.default.post(name: Notification.Name.messageReceived, object: nil, userInfo: ["message" : newMessage])
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
