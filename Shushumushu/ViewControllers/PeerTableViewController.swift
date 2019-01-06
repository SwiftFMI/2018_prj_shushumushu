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
        
        PeerService.peerService.serviceBrowser.invitePeer(PeerService.peerService.foundPeers[indexPath.row], to: PeerService.peerService.session, withContext: timestampData, timeout: 30)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
