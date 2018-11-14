//
//  NameEditorTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 13.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Notifications

extension Notification.Name {
    static let nameUpdated = Notification.Name("NameEditorTableVivarontrollerDidUpdateName")
}

//MARK: - NameEditorTableViewControllerDelegate

protocol NameEditorTableViewControllerDelegate: class {
    func NameEditorTableViewControllerDelegateDidUpdatePeerService(_ nameEditorTableViewController: NameEditorTableViewController)
}

class NameEditorTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    weak var delegate: NameEditorTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.text = PeerService.peerService.myPeerId.displayName
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightBarButtonTapped(_:)))
        
    }

    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem!) {
        if let text = nameTextField.text {
            PeerService.peerService = PeerService(text)
        }
        
        delegate?.NameEditorTableViewControllerDelegateDidUpdatePeerService(self)
        navigationController?.popViewController(animated: true)
    }
    

}

