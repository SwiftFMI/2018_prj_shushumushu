//
//  MCPeerID+Reusable.swift
//  Shushumushu
//
//  Created by Nikolay Slavkov on 31.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//
import MultipeerConnectivity

extension MCPeerID {
    public static func reusableInstance(withDisplayName displayName: String) -> MCPeerID {
        let defaults = UserDefaults.standard
        
        func newPeerID() -> MCPeerID {
            let newPeerID = MCPeerID(displayName: displayName)
            newPeerID.save(in: defaults)
            return newPeerID
        }
        
        let oldDisplayName = defaults.string(forKey: "kLocalPeerDisplayNameKey")
        
        if oldDisplayName == displayName {
            guard let peerData = defaults.data(forKey: "kLocalPeerIDKey"),
                let peerID = NSKeyedUnarchiver.unarchiveObject(with: peerData) as? MCPeerID
                else {
                    return newPeerID()
            }
            
            return peerID
            
        } else {
            return newPeerID()
        }
    }
    
    private func save(in userDefaults: UserDefaults) {
        let peerIDData = NSKeyedArchiver.archivedData(withRootObject: self)
        userDefaults.set(peerIDData, forKey: "kLocalPeerIDKey")
        userDefaults.set(displayName, forKey: "kLocalPeerDisplayNameKey")
        userDefaults.synchronize()
    }
}
