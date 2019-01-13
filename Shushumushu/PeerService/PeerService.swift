//
//  PeerService.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 12.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol PeerServiceDelegate: class {
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
    var currentTimestamp: TimeInterval
   
    var foundPeers = [MCPeerID]()
    var messages = [Message]()
    
    weak var delegate: PeerServiceDelegate?
    
    override init() {
        currentTimestamp = Date().timeIntervalSince1970
        
        super.init()
        
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["timestamp" : String(currentTimestamp)], serviceType: PeerServiceType)
        serviceAdvertiser.delegate = self

        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeerServiceType)
        serviceBrowser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    init(_ displayName: String) {
        currentTimestamp = Date().timeIntervalSince1970
        super.init()
        myPeerId = MCPeerID(displayName: displayName)
        
        session = MCSession(peer: myPeerId)
        session.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PeerServiceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()

        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["timestamp" : String(currentTimestamp)], serviceType: PeerServiceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension PeerService:  MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
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
        print("Received data from: \(peerID)")
        let receivedMessage = String(decoding: data, as: UTF8.self)
        print(receivedMessage)
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
//        let timestampData: Data?
//
//        do {
//            try timestampData = NSKeyedArchiver.archivedData(withRootObject: currentTimestamp, requiringSecureCoding: false)
//        } catch {
//            timestampData = nil
//            print("Error archiving timestamp data")
//        }
//        var nowInterval = Date().timeIntervalSince1970
//        let timestampData = Data(bytes: &nowInterval, count: MemoryLayout<TimeInterval>.size)
//        
//        browser.invitePeer(peerID, to: session, withContext: timestampData, timeout: 30)
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
        
        let timeInterval: Double = context!.withUnsafeBytes { $0.pointee }
        let date = Date(timeIntervalSince1970: timeInterval)
        
//        let inviterTimestamp: TimeInterval?
//        if let receivedContext = context {
//            do {
//                inviterTimestamp = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(receivedContext) as? TimeInterval
//            } catch {
//                inviterTimestamp = Date().timeIntervalSince1970
//                print("Error when receiving timestamp from peer \(peerID)")
//            }
//        } else {
//            inviterTimestamp = Date().timeIntervalSince1970
//        }
//
//        print("Received invitation from peer \(peerID) with timestamp \(inviterTimestamp)")
        invitationHandler(true, session)
        print("Received invitation from peer \(peerID) with timestamp \(date)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}
