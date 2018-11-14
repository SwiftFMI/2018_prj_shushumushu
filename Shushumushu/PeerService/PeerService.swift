//
//  PeerService.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 12.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol PeerServiceDelegate {
    func foundPeer()
    func lostPeer(at index: Int)
}

class PeerService: NSObject {
    
    static var peerService = PeerService()
    
    private let PeerServiceType = "ssms-mpc"
    
    var session : MCSession!
    var myPeerId : MCPeerID!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
   
    var foundPeers = [MCPeerID]()
   
    var delegate: PeerServiceDelegate?
    
    override init() {
        super.init()
        
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: myPeerId)
        session.delegate = self
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: PeerServiceType)
        serviceAdvertiser.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeerServiceType)
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    init(_ displayName: String) {
        super.init()
        myPeerId = MCPeerID(displayName: displayName)
        
        session = MCSession(peer: myPeerId)
        session.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeerServiceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: PeerServiceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension PeerService :  MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(peerID) changed state to: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data from: \(peerID)")
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
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer with id: \(peerID)")
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer with id: \(peerID)")
        
        var atIndex: Int!
        
        for (index, peer) in foundPeers.enumerated() {
            if peer == peerID {
                foundPeers.remove(at: index)
                atIndex = index
                break
            }
        }
        
        delegate?.lostPeer(at: atIndex)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from peer \(peerID)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}
