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
    var chatPartner: MCPeerID?
    
    required init?(coder aDecoder: NSCoder) {
        chatPartner = nil
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Initiated chat with: \(String(describing: chatPartner))")
    }

}
