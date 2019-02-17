//
//  PeerTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 11.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Class Definition

class PeerTableViewController: UITableViewController   {
    let cellIdentifier = "PeerTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = UserDefaults.standard.string(forKey: "username")
        PeerService.shared.delegate = self
        tableView.tableFooterView = UIView()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = PeerService.shared.myPeerId.displayName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatViewController" {
            let chatViewController = segue.destination as! ChatViewController
            let participantMCPeerID = sender as! MCPeerID
            chatViewController.chatPartner = participantMCPeerID
        }
    }
}

// MARK: - Pull to refresh

extension PeerTableViewController {
    
    @objc func refresh() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

// MARK: - PeerServiceDelegate protocol

extension PeerTableViewController: PeerServiceDelegate {
    
    func foundPeer() {
        tableView.insertRows(at: [IndexPath(row: PeerService.shared.foundPeers.count - 1, section: 0)], with: .automatic)
    }
    
    func lostPeer(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// MARK: - Table view data source

extension PeerTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PeerService.shared.foundPeers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PeerTableViewCell else {
            fatalError("The dequeued cell is not an instance of PeerTableViewCell")
        }
        
        let peer = PeerService.shared.foundPeers[indexPath.row]
        cell.peerName.text = peer.id.displayName
        cell.profilePicture.image = peer.profilePicture
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = PeerService.shared.foundPeers[indexPath.row].id
        PeerService.shared.serviceBrowser.invitePeer(selectedPeer, to: PeerService.shared.session, withContext: nil, timeout: 30)
        performSegue(withIdentifier: "ChatViewController", sender: selectedPeer)
    }
}
