//
//  ChatViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 9.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
     var chatPartner: MCPeerID?
    
    required init?(coder aDecoder: NSCoder) {
        chatPartner = nil
        super.init(coder: aDecoder)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Initiated chat with: \(String(describing: chatPartner))")
    }
    
    @IBAction func buttonSelected(_ sender: Any) {
        let messageData = textField.text?.data(using: String.Encoding.utf8)
        do {
            try PeerService.peerService.session.send(messageData!, toPeers: [chatPartner!], with: MCSessionSendDataMode.reliable)
        } catch {
            print("Error sending message")
        }
    }
    
}
