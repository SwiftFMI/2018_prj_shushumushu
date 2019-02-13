//
//  SettingsTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 13.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Class Definition

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceName.text = UserDefaults.standard.string(forKey: "username")
        
        if let profilePictureData = UserDefaults.standard.data(forKey: "profilePic") {
            profilePicture.image = UIImage(data: profilePictureData)
        }
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
    }
}

// MARK: - User Interactions
extension SettingsTableViewController {
    
    @IBAction func didChangeVisibility(_ sender: UISwitch) {
        if sender.isOn {
            PeerService.shared.serviceAdvertiser.startAdvertisingPeer()
            PeerService.shared.serviceBrowser.startBrowsingForPeers()
        }
        else {
            PeerService.shared.serviceAdvertiser.stopAdvertisingPeer()
            PeerService.shared.serviceBrowser.stopBrowsingForPeers()
        }
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "Logging out will result in loss of all your chats with nearby peers", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Log out", style: .destructive) { (action) in
            PeerService.logOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "setupViewController")
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController!.pushViewController(vc, animated: true)
        }
        alertController.addAction(destroyAction)
        
        present(alertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
