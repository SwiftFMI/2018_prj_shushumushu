//
//  SettingsTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 13.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceName.text = PeerService.peerService.myPeerId.displayName
        profilePicture.image = UIImage(data: UserDefaults.standard.data(forKey: "profilePic")!)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        
        guard let destination = segue.destination as? NameEditorTableViewController else { return }
        destination.delegate = self
    }
    
    @IBAction func didChangeVisibility(_ sender: UISwitch) {
        if sender.isOn {
            PeerService.peerService.serviceAdvertiser.startAdvertisingPeer()
            PeerService.peerService.serviceBrowser.startBrowsingForPeers()
        }
        else {
            PeerService.peerService.serviceAdvertiser.stopAdvertisingPeer()
            PeerService.peerService.serviceBrowser.stopBrowsingForPeers()
        }
    }
    
}

// MARK: - NameEditorTableViewControllerDelegate

extension SettingsTableViewController: NameEditorTableViewControllerDelegate {
    func NameEditorTableViewControllerDelegateDidUpdatePeerService(_ nameEditorTableViewController: NameEditorTableViewController) {
        deviceName.text = PeerService.peerService.myPeerId.displayName  
    }
}

