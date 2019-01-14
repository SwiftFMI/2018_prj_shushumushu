//
//  PeerTableViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 11.11.18.
//  Copyright © 2018 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerTableViewController: UITableViewController, PeerServiceDelegate   {
    let cellIdentifier = "PeerTableViewCell"
    
    func foundPeer() {
        tableView.insertRows(at: [IndexPath(row: PeerService.peerService.foundPeers.count - 1, section: 0)], with: .automatic)
    }
    
    func lostPeer(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = PeerService.peerService.myPeerId.displayName
        PeerService.peerService.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = PeerService.peerService.myPeerId.displayName
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PeerService.peerService.foundPeers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PeerTableViewCell else {
            fatalError("The dequeued cell is not an instance of PeerTableViewCell")
        }
        
        let peer: MCPeerID = PeerService.peerService.foundPeers[indexPath.row]
        cell.peerName.text = peer.displayName
        cell.peerNameInitialLetter.text = String(peer.displayName.dropLast(peer.displayName.count - 1))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nowInterval = Date().timeIntervalSince1970
        let timestampData = Data(bytes: &nowInterval, count: MemoryLayout<TimeInterval>.size)
        let selectedPeer = PeerService.peerService.foundPeers[indexPath.row]
        
        PeerService.peerService.serviceBrowser.invitePeer(selectedPeer, to: PeerService.peerService.session, withContext: timestampData, timeout: 30)
        performSegue(withIdentifier: "ChatViewController", sender: selectedPeer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatViewController" {
            let chatViewController = segue.destination as! ChatViewController
            let participantMCPeerID = sender as! MCPeerID
            chatViewController.chatPartner = participantMCPeerID
        }
    }
}
