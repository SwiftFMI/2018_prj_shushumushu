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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceName.text = PeerService.peerService.myPeerId.displayName
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

